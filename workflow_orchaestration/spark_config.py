
from pyspark.conf import SparkConf
from pyspark.context import SparkContext
from pyspark.sql import SparkSession
import pyspark
from pyspark.sql.functions import col, split, when


def config():

    credentials_location = '/home/abhi/gcp_keys/keys/my-terra-creds.json'

    conf = SparkConf() \
        .setMaster("local[*]") \
        .setAppName("test") \
        .set(
            "spark.jars",
            "/home/abhi/notebooks/lib/gcs-connector-hadoop3-2.2.5.jar, /home/abhi/notebooks/lib/spark-3.2-bigquery-0.29.0-preview.jar",) \
        .set("spark.hadoop.google.cloud.auth.service.account.enable", "true") \
        .set(
            "spark.hadoop.google.cloud.auth.service.account.json.keyfile",
            credentials_location,
        ) \
        .set("spark.executor.memory", "4g") \
        .set("spark.driver.memory", "4g")
        

    # hadoop configurations
    sc = SparkContext(conf=conf)
    hadoop_conf = sc._jsc.hadoopConfiguration()

    hadoop_conf.set(
        "fs.AbstractFileSystem.gs.impl", "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS"
    )
    hadoop_conf.set(
        "fs.gs.impl", "com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem"
    )
    hadoop_conf.set("fs.gs.auth.service.account.json.keyfile", credentials_location)
    hadoop_conf.set("fs.gs.auth.service.account.enable", "true")

    # creating spark session
    spark = SparkSession.builder.config(conf=sc.getConf()).getOrCreate()

    return spark

if __name__=="__main__":
    config()
