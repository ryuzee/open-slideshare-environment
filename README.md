# open-slideshare-environment

Development environment for open-slideshare.

## For AWS User!!

If you want to run this app on AWS, you can use a simple CloudFormation Template [here](https://raw.githubusercontent.com/ryuzee/open-slideshare-environment/master/aws_cfn_single.template). This template will create a VPC, 4 subnets for both private and public, required S3 buckets, SQS queue, IAM Role and so on. When you run this template, only you need to do is to wait around 15 minutes with coffee.

This template is only for Tokyo region (ap-northeast-1). If you want to run the app in other region, you need to customize both this CFn template and install.sh.

## Set up environment variables

You need to set environment variables as follows in your computer. (For example, set these variables in your ~/.zshrc, ~/bashrc or other scripts)

* DO NOT SET OSS_AWS_ACCESS_ID and OSS_AWS_SECRET_KEY if you run the application on Amazon EC2.
* YOU NEED TO CREATE specific IAM user to call AWS API. DO NOT USE MASTER ACCOUNT's credential.

```
OSS_AWS_ACCESS_ID
OSS_AWS_SECRET_KEY
OSS_BUCKET_NAME
OSS_IMAGE_BUCKET_NAME
OSS_REGION
OSS_SQS_URL
OSS_USE_S3_STATIC_HOSTING
OSS_CDN_BASE_URL
```

## Clone application

You need to specify destination directry named "application". This "application" directory will be shared among guest environment by Vagrant.

```
git clone https://github.com/ryuzee/open-slideshare application
```

## Install required gem and cookbooks

```
bundle install
bundle exec berks vendor cookbooks
```

## Start vagrant

```
vagrant up --provision
```

It will take more than 5 minutes to install and configure several packages.

After launching virtual machine, login to the machine and go forward the installation process. See more details https://github.com/ryuzee/open-slideshare
