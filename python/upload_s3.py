import boto3
import json
import requests
import logging
from botocore.exceptions import ClientError

S3_BUCKET = "bucket-test-20230504222500"
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
    except ClientError as e:
        logging.error(e)
        return False
    return True

def lambda_handler():
    response = requests.get(BASE_URL)

    if response.status_code == 200:
        data = response.json()
        print(data)
        # upload_json(data, bucket_name=S3_BUCKET, object_name='test_1')
        for obj in data:
            upload_json(obj, bucket_name=S3_BUCKET, object_name=obj['uid'])
        return True
    else:
        print(f"Error: {response.status_code} - {response.text}")
        return False
    
def main():
    lambda_handler()

if __name__ == '__main__':
    main()


