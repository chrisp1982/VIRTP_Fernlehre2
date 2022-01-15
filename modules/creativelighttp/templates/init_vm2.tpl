#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo mkdir /home/ec2-user/web
sudo echo  "${vm2_index}" > /home/ec2-user/web/index.html

sudo service docker start
sudo usermod -a -G docker ec2-user

sudo docker run -d --rm -t -v /home/ec2-user/web:/var/www/localhost/htdocs -p 8080:80 sebp/lighttpd
