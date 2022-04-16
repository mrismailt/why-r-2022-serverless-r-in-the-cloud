# Why R? 2022: Serverless R in the Cloud
## Deploying R into Production with AWS and Docker
### By Ismail Tigrek ([linkedin.com/in/ismailtigrek](https://www.linkedin.com/in/ismailtigrek/))
For my Why R? Turkey 2022 presentation

This tutorial will walk through deploying R code, machine learning models, or Shiny applications in the cloud environment. With this knowledge, you will be able to take any local R-based project you’ve built on your machine or at your company and deploy it into production on AWS using modern serverless and microservices architectures. In order to do this, you will learn how to properly containerize R code using Docker, allowing you to create reproducible environments. You will also learn how to set up event-based and time-based triggers. We will build out a real example that reads in live data, processes it, and writes it into a data lake, all in the cloud.

This tutorial has been publish inthe Why R? 2022 Abstact Book: [link](https://whyr.pl/2022/turkey/abstract_book/konu%C5%9Fmalar.html#serverless-r-in-the-cloud---deploying-r-into-production-with-aws-and-docker)

![image](https://user-images.githubusercontent.com/6436162/163592027-e2bc34d2-5106-404b-b430-23da5d807f91.png)


# AWS Resources

These are the AWS resources and their names as used in this codebase. You will need to change the names in your version of the code to match the names of your resources. You should be able to create all the resources below with the same names except for the S3 buckets.

### S3 Buckets: _whyr2022input_, _whyr2022output_

### ECR Repository: _whyr2022_

### ECS Cluster: _ETL_

### ECS Task: _whyr2022_

### EventBridge Rule: _whyr2022input_upload_

# Setting Up

## AWS

1. [Create and activate an AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
2. Create an IAM user called ETL that with the AdministratorAccess policy and save the Access keys (we will need them later)
3. Create two buckets:
  - For data input: _whyr2022test_
    - Set EventBridge events to on
  - For image outputs: _whyr2022testoutput_
4. Set up CloudTrial data events (link)

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

This was only meant to be a breif tutorial to fit into 30 minutes. Many crucial steps were overlooked for the sake of brevity. Ideally, you should look at doing the following:

## Create an IAM user for your production code

We used the access keys of our root AWS account. This is not ideal for security reasons. Use your root account to create an admin user for yourself. Then lock the root credentials away and never use them again unless absolutley necessary. Then, using your new admin account, create another IAM user for your production code. Replace the access keys in your .secrets file with access keys from this account

## Remove access keys from your code

Ideally, you don't want to store your access keys inside your code or docker image. Instead, pass in security keys as environment variables when creating your ECS task defintion

- Upload script to S3, make general image
- Edge cases
- Terraform
- Mark used files
