#!/bin/bash
JDK_FILENAME=java-11-amazon-corretto-devel-11.0.2.9-1.x86_64.rpm
JDK_CHECKSUM="34ee8422ae5f5695c8052cbd7a57df8a"

echo "Install WGET"
sudo yum install wget -y

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

echo "Install logstash agent"
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo tee /etc/yum.repos.d/logstash.repo  <<EOL
[logstash-6.x] 
name=Elastic repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1 
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch 
enabled=1
autorefresh=1
type=rpm-md
EOL
sudo yum install logstash -y

echo "Start tomcat"
sudo tomcat start
#sudo systemctl start logstash.service