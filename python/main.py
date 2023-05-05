import boto3
import json
import requests
import logging
from botocore.exceptions import ClientError
import os 

# S3_BUCKET = "api-staging-bucket-20230505" #actual

S3_BUCKET_NAME = os.environ['S3_BUCKET_NAME']

BASE_URL = "https://random-data-api.com/api/v2/users?size=2&response_type=json"

def upload_json(data, bucket_name, object_name=None):
    """Upload a file to an S3 bucket
    :param file_name: File to upload
    :param bucket: Bucket to upload to
    :param object_name: S3 object name. If not specified then file_name is used
    :return: True if file was uploaded, else False
    """
    # Upload the file
    s3_client = boto3.client('s3')
    try:
        data_json = json.dumps(data)
        s3_client.put_object(Bucket=bucket_name, Key=object_name, Body=data_json)
        print('success put_object')
        print(data_json)
    except ClientError as e:
        logging.error(e)
        return False
    return True

def lambda_handler(event, context):
    # send GET request
    response = requests.get(BASE_URL)

    if response.status_code == 200:
        data = response.json()
        for obj in data:
            upload_json(obj, bucket_name=S3_BUCKET_NAME, object_name=obj['uid'])
        return {
        'statusCode': 200,
        'body': json.dumps(data)
        }
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return {
        'statusCode': 400,
        'body': json.dumps(f"Error: {response.status_code} - {response.text}")
        }
