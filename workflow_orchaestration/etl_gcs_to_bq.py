from pyspark.sql import SparkSession
from pyspark.sql.functions import to_timestamp
from pyspark.sql.types import StringType, IntegerType
from pyspark.sql.functions import col, split, when
import os
os.environ['PYSPARK_SUBMIT_ARGS'] = '--master local[*] pyspark-shell'
from tqdm import tqdm
from pathlib import Path
from prefect import flow, task
from prefect_gcp import GcpCredentials
from pyspark.sql import functions as F
from spark_config import config
import requests
from pathlib import Path





@task(log_prints = True, name = "Reading from GCS bucket")
def read_from_gcs_transform(y:int,m:int,d:int,bucket_name:str):
    df = spark.read.parquet(f"gs://{bucket_name}/{y}/{m:02}/{d:02}/*")
    df = df.withColumn("actor_id", col("actor.id"))
    df =df.withColumn("actor_login", col("actor.login"))
    df =df.withColumn("repo_id", col("repo.id"))
    df = df.withColumn("repo_name", col("repo.name"))
    df = df.withColumn("payload_size", when(col("payload.size").isNotNull(), col("payload.size")).otherwise(0))
    df = df.withColumn('org_present', when(col('org').isNull(), 'No').otherwise('Yes'))

    selected_columns = ["id", "type", "created_at", "actor_id", "actor_login", "repo_id", "repo_name", "payload_size", "org_present"]
    # print(df.head(2))
    df = df.select(*selected_columns)
    df = df.withColumn("created_at", to_timestamp(df["created_at"], "yyyy-MM-dd'T'HH:mm:ss'Z'"))
    df = df.withColumn('actor_id', df['actor_id'].cast(StringType()))
    df = df.withColumn('repo_id', df['repo_id'].cast(StringType()))
    df = df.withColumn('payload_size', df['payload_size'].cast(IntegerType()))
    df = df.withColumn("org_present", col("org_present").cast(StringType()))
    df = df.withColumn("org_present", when(col("org_present") == "", None).otherwise(col("org_present")))
    null_count = df.filter(F.col("id").isNull()).count()
    print(null_count)
    print(df.count())
   
    # df = df.limit(1000000)
    # df = df.repartition("created_at")
    # print(df.head(2))

    # print(df.columns)
    print("operations completed on dataset")
    
    print(df.printSchema())
    return(df)

@task(log_prints = True, name = "writing to bq table")   
def write_to_bq(df, project_id, schema_name, table_name):
    print("started")
   
    df_repartitioned = df.repartition(40)

    # Write to BigQuery
    df_repartitioned.write \
        .format("bigquery") \
        .mode("append") \
        .option("writeMethod", "direct") \
        .option("partitionBy", "created_at") \
        .option("partitionField", "created_at") \
        .save(f"{project_id}.{schema_name}.{table_name}")


    print("data write to bigquery successful")



@flow(log_prints = True, name = "Github analytics data upload")
def data_upload(y:int,m:int,d:int) -> None:
    bucket_name = "dataengineering1-433721_github_analytics"
    global spark 
    spark = config()
   
    df = read_from_gcs_transform(y,m,d, bucket_name)
    project_id = "dataengineering1-433721"
    schema_name = "gitanalytics_de"
    table_name = "gitanalytics_raw_data"
    write_to_bq(df,project_id,schema_name,table_name )
    spark.stop()






@flow(log_prints = True, name = "Github analytics data upload timeframe")
def data_timeframe(year_:list, month:list, day:list) -> None:
    for y in year_:
        for m in month:
            for d in day:
                print(y,m,d)
                data_upload(y,m,d)



if __name__ == "__main__":
    year_ = [2022]
    month = [1]
    day = [10]
    data_timeframe(year_,month, day)