import time
import argparse
import boto3
from prometheus_client import start_http_server, Gauge

S3_SIZE = Gauge('s3_bucket_size_bytes', 'Total size of bucket in bytes', ['bucket_name'])

def fetch_s3_metrics():
    s3_res = boto3.resource('s3')
    s3_client = boto3.client('s3') # Client is needed for the get_bucket_tagging method
    
    for bucket in s3_res.buckets.all():
        try:
            # Check for the specific project tag
            response = s3_client.get_bucket_tagging(Bucket=bucket.name)
            tags = {t['Key']: t['Value'] for t in response['TagSet']}
            
            if tags.get('project') == 'monitoring-system':
                size = sum(obj.size for obj in bucket.objects.all())
                S3_SIZE.labels(bucket_name=bucket.name).set(size)
            else:
                # Optional: Remove buckets from metrics if the tag is removed
                S3_SIZE.remove(bucket.name)
        except s3_client.exceptions.ClientError as e:
            # Handle buckets with no tags
            if e.response['Error']['Code'] == 'NoSuchTagSet':
                S3_SIZE.remove(bucket.name)
            continue
        except Exception as e:
            print(f"S3 Error for {bucket.name}: {e}")

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=9201)
    args = parser.parse_args()

    start_http_server(args.port)
    while True:
        try:
            fetch_s3_metrics()
        except Exception as e:
            print(f"Global S3 Error: {e}")
        time.sleep(300)