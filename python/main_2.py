import boto3
import json
import requests
import logging
from botocore.exceptions import ClientError

BASE_URL = "https://random-data-api.com/api/v2/users?size=1&response_type=json"

def lambda_handler(event, context):
    # TODO implement
    response = requests.get(BASE_URL)
    if response.status_code == 200:
        data = response.json()
        print(data)
        
        return {
        'statusCode': 200,
        'body': json.dumps(data)
        }

    else:
        return {
        'statusCode': 400,
        'body': json.dumps(f"Error: {response.status_code} - {response.text}")
        }
