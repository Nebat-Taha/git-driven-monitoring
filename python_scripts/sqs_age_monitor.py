import time
import argparse
import boto3
from prometheus_client import start_http_server, Gauge

# 1. DEFINE THE METRIC
# Gauge is perfect for 'Age' because it can go up and down.
SQS_AGE = Gauge(
    'sqs_oldest_message_age_seconds', 
    'Age of the oldest message in the queue', 
    ['queue_name']
)

def fetch_metrics(region):
    sqs = boto3.client('sqs', region_name=region)
    
    # List all queues to make this "Zero-Touch"
    queues = sqs.list_queues().get('QueueUrls', [])
    
    for url in queues:
        name = url.split('/')[-1]
        attributes = sqs.get_queue_attributes(
            QueueUrl=url,
            AttributeNames=['ApproximateAgeOfOldestMessage']
        )
        age = int(attributes['Attributes']['ApproximateAgeOfOldestMessage'])
        
        # Update the Prometheus Gauge with the Label
        SQS_AGE.labels(queue_name=name).set(age)

if __name__ == '__main__':
    # 2. HANDLE DYNAMIC PORT (From Ansible)
    parser = argparse.ArgumentParser()
    parser.add_argument('--port', type=int, default=9200, help='Port to serve metrics')
    args = parser.parse_args()

    # 3. START THE SERVER
    print(f"Starting SQS Exporter on port {args.port}...")
    start_http_server(args.port)
    
    # 4. LOOP & SCRAPE
    while True:
        try:
            fetch_metrics('us-east-1')
        except Exception as e:
            print(f"Error fetching AWS metrics: {e}")
        
        time.sleep(30) # Scrape AWS every 30 seconds