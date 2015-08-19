# open-slideshare-environment

Development environment for open-slideshare.

## Set up environment variables

You need to set environment variables as follows in your computer. (For example, set these variables in your ~/.zshrc, ~/bashrc or other scripts)

* DO NOT SET AWS_ACCESS_ID and AWS_SECRET_KEY if you run the application on Amazon EC2.
* YOU NEED TO CREATE specific IAM user to call AWS API. DO NOT USE MASTER ACCOUNT's credential.

```
# AWS
AWS_ACCESS_ID
AWS_SECRET_KEY
# OpenSlideshare
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
