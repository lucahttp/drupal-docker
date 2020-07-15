FROM ubuntu:latest


# File Author / Maintainer
LABEL author="lukaneco"
LABEL maintainer="luca.sain@outlook.com"


ENV DEBIAN_FRONTEND=noninteractive


# ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=America/Argentina/Buenos_Aires

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone



#Quick Install Guide (Ubuntu)
#Drupal 8 has two main parts:
#-Database
#-Code

#In very simple terms:
#Database holds all changes you make to the content in the UI.
#The code defines how the content will be rendered and styled among other things.

#Install Apache (WebServer):
RUN apt-get update
RUN apt-get install apache2 wget unzip zip -y
#RUN nano /etc/apache2/apache2.conf
#Change 'server_domain_or_IP' to 'localhost:80' on this line:
#ServerName server_domain_or_IP

#Download Drupal (Code):
#https://www.drupal.org/download
#Put it in a directory of your choosing.

WORKDIR /var/www/html/

# download drupal.zip
RUN echo "download" 
RUN wget https://www.drupal.org/download-latest/zip -O drupal.zip

# unzip drupal.zip
RUN unzip /var/www/html/drupal.zip
# delete drupal.zip
RUN rm -rf /var/www/html/drupal.zip
#rename
RUN mv drupal-* drupal

# move all files from wordpress temp directory to /var/www/html/
RUN mv -v /var/www/html/drupal/* /var/www/html/

# delete wordpress temp directory
#RUN rmdir /var/www/html/drupal-*/
RUN rm -rf /var/www/html/drupal/


#Link Apache to Drupal
#sudo nano /etc/apache2/conf/httpd.conf
#Change to the directory you downloaded Drupal to

#Start Apache:
RUN service apache2 start

#Install MySQL (Database)
#sudo apt-get install mysql-server

#Create a new Database:
#Login into MySQL
#CREATE DATABASE example;

#Install PHP (Coding language)
RUN apt-get -y install gcc make autoconf libc-dev pkg-config

RUN apt-get install php libapache2-mod-php libmcrypt mcrypt php-mcrypt php-mysql php-xml -y

#Go to http://localhost. Follow the prompts to link your database (use the name you created it with and your MySQL credentials).

#Now you have a Drupal site!
#Edit the code to change the styling, rendering and many other things.
#Add and create new types of content through the site UI.
#Add modules to add new functionality.


#Some guides to get started:


# RUN echo 'ServerName localhost' > /etc/apache2/apache2.conf

#RUN echo hostname -I
RUN ls /var/www/html/


# WORKDIR /var/www/html/
EXPOSE 80
# EXPOSE 443

# By default, simply start apache.
CMD apachectl -D FOREGROUND