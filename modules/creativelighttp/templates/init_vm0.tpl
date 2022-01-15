#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo mkdir /home/ec2-user/web
sudo service docker start
sudo usermod -a -G docker ec2-user

while true
do
sudo rm -f /home/ec2-user/web/index.html
sudo wget ${vm1_host}:8080 -P /home/ec2-user/web
sudo docker run --name theonlyone -d --rm -t -v /home/ec2-user/web:/var/www/localhost/htdocs -p 8080:80 sebp/lighttpd
sudo sleep 5s
sudo docker stop theonlyone

sudo rm -f /home/ec2-user/web/index.html
sudo wget ${vm2_host}:8080 -P /home/ec2-user/web
sudo docker run --name theonlyone -d --rm -t -v /home/ec2-user/web:/var/www/localhost/htdocs -p 8080:80 sebp/lighttpd
sudo sleep 5s
sudo docker stop theonlyone
done