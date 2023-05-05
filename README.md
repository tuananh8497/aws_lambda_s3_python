# aws_lambda_s3_python

## Overview
The code will ingest data from Random API into AWS s3 Bucket on 5 minutes interval. The code was ran by Lambda Function that triggered by CloudWatch Events and can see the log on Cloud Watch monitor

## Pre-requisite

Installed [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#cliv2-linux-install)

```bash
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ unzip awscliv2.zip
$ sudo ./aws/install
$ aws configure
$ pip install boto3
```

Install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
```bash
$ sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```

Install [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
```bash
$ pip install boto3
```

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Assumption
  1. The IAM user that deployed the infrastructure has sufficient permission to apply and make change to the system
  2. The data stored is in json format that will be stored as-is, which will be used for transformation in the downstream process
  3. User has sufficient to create role, iam policy to archieve similar things
  4. This code is not for production purpose, therefore there will be reluctant on certain aspect, such as code format, security concerns, storage
  5. Data store in s3 is unstructure raw data, therefore will be needed further cleaning and transformation to be usable