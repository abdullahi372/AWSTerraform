#! /bin/bash
sudo apt-get update
sudo apt-get install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
