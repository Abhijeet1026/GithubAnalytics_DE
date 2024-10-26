from pyspark.sql import SparkSession
from pyspark.sql.functions import col, split, when

from pathlib import Path
from prefect import flow, task
from prefect_gcp import GcpCredentials
from spark_config import config
import requests
import os
from pathlib import Path


@task(log_prints = True, name = "download files locally")
def local_download(path: Path, y:int, m:int, d:int):
    for period in range(1,24):
    
        url = f"https://data.gharchive.org/{y}-{m:02}-{d:02}-{period}.json.gz"
        print(url)
        os.system(f"wget -P {path} {url}")


@task(log_prints = True, name = "write files to GCS from local")
def write_to_gcs(path:Path,y:int,m:int,d:int, bucket_name:str):
    df = spark.read.json(f"{path}/*")
    # print(df.count())
    df.write.parquet(
        f"gs://{bucket_name}/{y}/{m:02}/{d:02}", mode="overwrite"
    )

@task(log_prints = True, name = "cleaning_local")
def clean_local(path:Path):
    os.system(f"rm -r {path}")
    print(f"successfully removed content in {path}")
    return None


@flow(log_prints = True, name = "Github analytics data download using api")
def data_api(y:int,m:int, d:int) -> None:
    bucket_name = "dataengineering1-433721_github_analytics"
    path = Path(f"/home/abhi/data/{y}/{m:02}/{d:02}")
    global spark 
    spark = config()
    local_download(path, y, m ,d)
    write_to_gcs(path,y,m,d, bucket_name)
    clean_local(path)
    spark.stop()

@flow(log_prints = True, name = "Github analytics data download timeframe")
def data_timeframe(year_:list, month:list, day: list) -> None:
    for y in year_:
        for m in month:
            for d in day:
                print(y,m,d)
                data_api(y,m,d)


if __name__ == "__main__":
    year_ = [2022]
    month = [1]
    day = [1,2,3,4,5,6,7,8,9,10]
    data_timeframe(year_,month, day)
    
