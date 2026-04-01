import time
import argparse
import boto3
from prometheus_client import start_http_server, Gauge

S3_SIZE = Gauge('s3_bucket_size_bytes', 'Total size of bucket in bytes', ['bucket_name'])

def fetch_s3_metrics():
    s3 = boto3.resource('s3')
    for bucket in s3.buckets.all():
        size = sum(obj.size for obj in bucket.objects.all())
        S3_SIZE.labels(bucket_name=bucket.name).set(size)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=9201)
    args = parser.parse_args()

    start_http_server(args.port)
    while True:
        try:
            fetch_s3_metrics()
        except Exception as e:
            print(f"S3 Error: {e}")
        time.sleep(300) # S3 storage doesn't change fast; 5 mins is plenty