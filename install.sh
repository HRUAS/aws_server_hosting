#!/bin/bash

sudo yum update -y
sudo yum install -y amazon-efs-utils 
sudo yum install python -y
sudo yum install pip -y
sudo mkdir /mnt/efs 
sudo mount -t efs -o tls fs-00899043510054dbc:/ /mnt/efs/ 
sudo echo "fs-00899043510054dbc.efs.us-east-1.amazonaws.com:/ /mnt/efs efs _netdev,tls 0 0" >> /etc/fstab
sudo mount -a
sudo chown -R ec2-user: /mnt/efs/
mkdir /mnt/efs/jenkins_home
mkdir /mnt/efs/code_server

# installing docker
sudo yum install docker -y 
sudo usermod -aG docker ec2-user 
sudo systemctl restart docker

# install docker compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# pull the compose file for servers
cd /home/ec2-user/aws_server_hosting
pip install -r requirements.txt
mkdir ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/nginx-selfsigned.key \
  -out ssl/nginx-selfsigned.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=localhost"
sudo chown -R ec2-user: /home/ec2-user/aws_server_hosting
docker-compose up -d code-server nginx
# docker-compose up -d jenkins
sudo -u ec2-user bash -c 'echo "all done" >> /home/ec2-user/all_done.flag'
echo "alias gotocode='cd /mnt/efs/code_server/config/workspace; ls -lrt'" >> /home/ec2-user/.bashrc
