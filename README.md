# Why R? 2022: Serverless R in the Cloud
## Deploying R into Production with AWS and Docker
### By Ismail Tigrek ([linkedin.com/in/ismailtigrek](https://www.linkedin.com/in/ismailtigrek/))
As presented in the Why R? Turkey 2022 conference

This tutorial will walk through deploying R code, machine learning models, or Shiny applications in the cloud environment. With this knowledge, you will be able to take any local R-based project you’ve built on your machine or at your company and deploy it into production on AWS using modern serverless and microservices architectures. In order to do this, you will learn how to properly containerize R code using Docker, allowing you to create reproducible environments. You will also learn how to set up event-based and time-based triggers. We will build out a real example that reads in live data, processes it, and writes it into a data lake, all in the cloud.

This tutorial has been published in the Why R? 2022 Abstract Book: [link](https://whyr.pl/2022/turkey/abstract_book/konu%C5%9Fmalar.html#serverless-r-in-the-cloud---deploying-r-into-production-with-aws-and-docker)

![image](https://user-images.githubusercontent.com/6436162/163592027-e2bc34d2-5106-404b-b430-23da5d807f91.png)


# AWS Resources

These are the AWS resources and their names as used in this codebase. You will need to change the names in your version of the code to match the names of your resources. You should be able to create all the resources below with the same names except for the S3 buckets.

#### S3 Buckets: _whyr2022input_, _whyr2022output_

#### ECR Repository: _whyr2022_

#### ECS Cluster: _ETL_

#### ECS Task: _whyr2022_

#### EventBridge Rule: _whyr2022input_upload_

# Setting Up

## AWS

1. [Create and activate an AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
2. [Retrieve access keys](https://www.msp360.com/resources/blog/how-to-find-your-aws-access-key-id-and-secret-access-key/)
3. Create S3 buckets
 - Create input bucket (_whyr2022test_)
 - Creat output bucket (_whyr2022testoutput_)
 - [Enable CloudTrail event logging for S3 buckets and objects](https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-cloudtrail-logging-for-s3.html)

4. Create ECR repository (_whyr2022_)
5. Creaet ECS cluster (_ETL_)
6. Create ECS task defintion (_whyr2022_)
7. Create EventBridge rule (_whyr2022input_upload_)
 - Create event pattern

```
{
  "source": ["aws.s3"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["s3.amazonaws.com"],
    "eventName": ["PutObject"],
    "requestParameters": {
      "bucketName": ["whyr2022input"]
    }
  }
}
```
- Set target to ECS task _whyr2022_ in ECS cluster _ETL_

## Your Computer
1. [Install and setup Docker Desktop](https://docs.docker.com/desktop/windows/install/)
2. [Install and setup AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. [Create named AWS profile called (_whyr2022_)](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)
4. Put access keys into _.secrets_ 

# Deployment
1. Authenticate Docker client to registry
```
aws ecr get-login-password --region us-east-1 --profile whyr2022 | docker login --username AWS --password-stdin 631607388267.dkr.ecr.us-east-1.amazonaws.com
```
2. Build Docker image
```
docker build -t whyr2022 .
```
3. Run Docker image locally to test
```
docker run whyr2022
```
4. Tag Docker image
```
docker tag whyr2022:latest 631607388267.dkr.ecr.us-east-1.amazonaws.com/whyr2022:latest
```
5. Push Docker image to AWS ECR
```
docker push 631607388267.dkr.ecr.us-east-1.amazonaws.com/whyr2022:latest
```

## View logs

You can view the logs of all container runs in AWS CloudWatch under Log Groups

# Further steps

This was only meant to be a brief tutorial to fit into 30 minutes. Many crucial steps were overlooked for the sake of brevity. Ideally, you should look at doing the following:

## Create an IAM user for your production code

We used the access keys of our root AWS account. This is not ideal for security reasons. Use your root account to create an admin user for yourself. Then lock the root credentials away and never use them again unless absolutely necessary. Then, using your new admin account, create another IAM user for your production code. Replace the access keys in your .secrets file with access keys from this account

## Remove access keys from your code

Ideally, you don't want to store your access keys inside your code or docker image. Instead, pass in security keys as environment variables when creating your ECS task definition

## Replace Docker image with a general image

We baked our script into our Docker image. This is not ideal since every time you update your code, you will need to rebuild your Docker image and re-push to ECR. Instead, create a general Docker image that can read in the name of a script to pull from an S3 bucket (you can pass this name in as an ECS task environment variable). This way, you can have a bucket that contains your R scripts, and you will only need to build your Docker image once. Every time your container is deployed, it will pull the latest version of your script from the S3 bucket.

## Make code more robust

Our script is running on a lot of assumptions, such as:
- only one file is uploaded to _whyr2022input_ at a time
- only RDS files are uploaded to _whyr2022input_
- the files uploaded to _whyr2022input_ are dataframes with two numeric columns
- 
Production code should not run on any assumptions. Everything should be validated, and possible errors or edge cases should be gracefully handled.

Another thing that can be done to enhance the pipeline is to mark "used" input files. This can be done by appending "-used_<TIMESTAMP>" to the file name.

## Convert all infrastructure to code

We provisioned all our resources through the AWS Console. This is not ideal since we cannot easily recreate the allocation and configuration of these resources. Ideally, you want to codify this process using an Infrastructure-as-code solution (ex: Terraform)
