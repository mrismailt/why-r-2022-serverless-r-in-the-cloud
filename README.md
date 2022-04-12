# Why R? 2022: Serverless R in the Cloud
### By: [Ismail Tigrek](www.linkedin.com/in/ismailtigrek)
For my Why R? Turkey 2022 presentation

# AWS Resources (that are used in this codebase. You will need to change these based on your own resources)

### S3 Buckets: _whyr2022input_, _whyr2022output_

### ECR Repository: _whyr2022_

## ECS Cluster:

## ECS Task

## EventBridge Rule:

# Setting Up

## AWS

1. Create an IAM user called ETL that with the AdministratorAccess policy and save the Access keys (we will need them later)
2. Create two buckets:
  - For data input: _whyr2022test_
  - For image outputs: _whyr2022testoutput_

## Your Computer
1. Install and setup Docker Desktop (link)
2. Install and setup AWS CLI (link)
3. Create an AWS profile called etl-whyr2022 (link)
6. `docker make -t whyr2022 .`
7. 

## RStudio
1. Create .env file with acces keyhs 


# Deployment
1. `aws ecr get-login-password --region us-east-1 --profile iamadmin-whyr2022 | docker login --username AWS --password-stdin 631607388267.dkr.ecr.us-east-1.amazonaws.com`
2. `docker build -t whyr2022 .`
3. `docker tag whyr2022:latest 631607388267.dkr.ecr.us-east-1.amazonaws.com/whyr2022:latest`
4. `docker push 631607388267.dkr.ecr.us-east-1.amazonaws.com/whyr2022:latest`

# Further steps

Suggestions on how yo ucan improve this

- Pass in keys
- Upload script to S3, make general image
