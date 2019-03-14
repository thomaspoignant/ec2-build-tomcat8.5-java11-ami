#!/bin/bash
WAR_URL=https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war
S3_BUCKET_NAME=s3-log-bucketname
AWS_REGION=eu-west-1
JDK_FILENAME=java-11-amazon-corretto-devel-11.0.2.9-1.x86_64.rpm
JDK_CHECKSUM="34ee8422ae5f5695c8052cbd7a57df8a"

echo "Increase ulimit"
sudo tee /etc/security/limits.conf <<EOL
root soft nofile 65536
root hard nofile 65536
EOL

echo "Download JAVA"
wget https://d2jnoze5tfhthg.cloudfront.net/$JDK_FILENAME

echo "Verify JAVA md5"
MD5_CHECKSUM=$(md5sum $JDK_FILENAME | cut -d\  -f1)
if [ "$JDK_CHECKSUM" != "$MD5_CHECKSUM" ]
then
    echo "Invalid checksum"
    exit 1;
fi

echo "Install JAVA"
sudo yum localinstall $JDK_FILENAME -y

echo "Install tomcat8.5"
sudo amazon-linux-extras install tomcat8.5 -y

echo "Configure tomcat8.5"
echo "Download and deploy webapp"
wget "$WAR_URL" -P /usr/share/tomcat/webapps/

echo "Install fluentd"
curl -L https://toolbelt.treasuredata.com/sh/install-amazon2-td-agent3.sh | sudo sh

echo "Install fluentd S3 plugin"
sudo /usr/sbin/td-agent-gem install install fluent-plugin-s3

echo "Fluentd configuration"
sudo chmod 777 /var/log/tomcat
sudo mkdir -p /var/log/td-agent/s3
sudo chown td-agent:td-agent /var/log/td-agent/s3

sudo tee /etc/td-agent/td-agent.conf <<EOL
<source>
  @type tail
  format none
  path /var/log/tomcat/*
  pos_file /var/log/td-agent/tomcat.pos
  tag tomcat.logs
</source>

<match tomcat.logs>
  @type s3
  s3_bucket $S3_BUCKET_NAME
  s3_region $AWS_REGION
  path logs/
  buffer_path /var/log/td-agent/s3
  time_slice_format %Y%m%d%H
  time_slice_wait 10m
  utc
  buffer_chunk_limit 256m
</match>
EOL

echo "Set Tomcat as a auto-start service (via chkconfig)"
chkconfig --add tomcat
chkconfig tomcat on

echo "Set fluentd as a auto-start service (via chkconfig)"
chkconfig --add td-agent
chkconfig td-agent on
