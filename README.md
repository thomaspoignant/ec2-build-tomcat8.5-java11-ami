# ec2-build-java-tomcat-ami

This is a user-data allow to create an AMI from a [Amazon Linux](https://aws.amazon.com/amazon-linux-ami/) with [Java 11 AWS Corretto](https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/what-is-corretto-11.html).
It also add a [fluentd](https://www.fluentd.org/) agent to push log on S3.


## How to start an EC2 with user-data
Follow the instructions here : https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
