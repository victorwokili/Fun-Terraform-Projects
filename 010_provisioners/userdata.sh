#!/bin/bash
		yum update -y
		yum install -y httpd.x86_64
		systemctl start httpd.service
		systemctl enable httpd.service
		echo ?Hello World from Server 1, $(hostname -f)? > /var/www/html/index.html