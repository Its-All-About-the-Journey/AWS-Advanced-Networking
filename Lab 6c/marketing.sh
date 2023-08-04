#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo chmod 777 /var/www/html
cd /var/www/html
echo "<!DOCTYPE html><html><head><title>Marketing Department</title></head><body><h1>Marketing Department</h1><p>This is the Marketing department web page.</p></body></html>" > marketing.html
