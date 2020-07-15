FROM ubuntu:latest


# File Author / Maintainer
LABEL author="lukaneco"
LABEL maintainer="luca.sain@outlook.com"


## seteando lenguaje
ENV OS_LOCALE="es_AR.UTF-8"
RUN apt-get update && apt-get install -y apt-utils locales && locale-gen ${OS_LOCALE}
ENV LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
    DEBIAN_FRONTEND=noninteractive


# ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=America/Argentina/Buenos_Aires

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update the repository sources list
# RUN apt-get update

# Install and run apache
RUN apt-get install -y apache2 php php-mysql php-mbstring php-xml php-gd wget curl unzip zip && apt-get clean


# delete all file of the html folder
RUN rm -R /var/www/html/*

# set permisions on the html folder
RUN	chown www-data:www-data /var/www/html/ -Rf

#ENTRYPOINT ["/usr/sbin/apache2", "-k", "start"]
#RUN service apache2 restart


# https://projects.raspberrypi.org/en/projects/lamp-web-server-with-wordpress/4
# https://pimylifeup.com/raspberry-pi-wordpress/

#RUN cd /var/www/html
#RUN wget http://wordpress.org/latest.tar.gz
#RUN tar xzf latest.tar.gz
#RUN mv wordpress/* ./
#RUN rm -rf wordpress latest.tar.gz
#RUN usermod -a -G www-data pi
#RUN chown -R -f www-data:www-data /var/www/html



# https://raspberrytips.com/wordpress-on-raspberry-pi/
# RUN wget https://wordpress.org/latest.zip -O /var/www/html/wordpress.zip



# Installing composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


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

RUN usermod -a -G www-data root
#RUN chown -R -f www-data:www-data /var/www/html

RUN	chown www-data:www-data /var/www/html/ -Rf

RUN a2enmod rewrite

#RUN sed -i -r "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

# nano  /etc/apache2/sites-available/000-default.conf

# nano /etc/apache2/sites-available/default-ssl.conf


#RUN sed -i -r "s/AllowOverride None/AllowOverride All/g" /etc/apache2/sites-available/default
#RUN sed -i -r "s/AllowOverride None/AllowOverride All/g" /etc/apache2/sites-available/default-ssl

#$databases['default']['default'] = [
#           'database' => 'databasename',
#           'username' => 'sqlusername',
#           'password' => 'sqlpassword',
#           'host' => 'localhost',
#           'port' => '3306',
#           'driver' => 'mysql',
#           'prefix' => '',
#           'collation' => 'utf8mb4_general_ci',

#
#         //$databases = [];
#$databases['default']['default'] = ['database' => 'mydb','username' => 'admin','password' => 'admin','host' => 'db','port' => '3306','driver' => 'mysql','prefix' => 'dp_','collation' => 'utf8mb4_general_ci',];
#sites/default/settings.php

RUN cp /var/www/html/sites/default/default.settings.php /var/www/html/sites/default/settings.php

RUN chmod 777 /var/www/html/sites/default/settings.php
#RUN sed -i -r "s/$databases = [];/$databases['default']['default'] = ['database' => 'mydb','username' => 'admin','password' => 'admin','host' => 'db','port' => '3306','driver' => 'mysql','prefix' => 'dp_','collation' => 'utf8mb4_general_ci',];/g" sites/default/settings.php
#RUN sed -i -r '/$databases = [];/c\$databases['default']['default'] = ['database' => 'mydb','username' => 'admin','password' => 'admin','host' => 'db','port' => '3306','driver' => 'mysql','prefix' => 'dp_','collation' => 'utf8mb4_general_ci',];' sites/default/settings.php
RUN cat sites/default/settings.php
RUN sed -i -r "s/AllowOverride None/AllowOverride All/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i -r "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

RUN apt-get install perl nano -y
#RUN perl -0777 -pe 's/(.*<Directory '/var/www/html'>[^\n]*)/$1\nAllowOverride All/s' /etc/apache2/sites-available/000-default.conf

# RUN find /etc -name httpd* -or find /etc -name apache2* 

RUN apache2ctl -M | grep -i write

#RUN chmod 755 wordpress -R
#RUN chown www-data wordpress -R

#https://www.configserverfirewall.com/ubuntu-linux/install-apache-php-mysql-ubuntu-18/
# RUN mkdir /var/www/mywordpress.ga
#RUN vim /etc/apache2/sites-available/example.com.conf

#ENV APACHE_RUN_USER www-data
#ENV APACHE_RUN_GROUP www-data
#ENV APACHE_LOG_DIR /var/log/apache2


# https://stackoverflow.com/questions/6233398/download-and-insert-salt-string-inside-wordpress-wp-config-php-with-bash
# RUN cat wp-config.php | sed 's/old_string/new_string/g' > wp-config.php


# ARG DB_NAME="db"
# ENV DB_NAME=$DB_NAME
# ENV VARIABLE_FOR_DOCKER_COMPOSE_1=yet_another_value


# https://vsupalov.com/docker-arg-env-variable-guide/

# ARG some_variable_name
# or with a hard-coded default:
# ARG some_variable_name=default_value

# RUN echo "Oh dang look at that $some_variable_name"
# you could also use braces - ${some_variable_name}



## Woocommerce
# https://wordpress.org/plugins/woocommerce/
# https://wordpress.org/support/article/managing-plugins/#manual-plugin-installation
#RUN echo "download" 
#RUN wget https://downloads.wordpress.org/plugin/woocommerce.zip -O /var/www/html/wp-content/plugins/woocommerce.zip


# unzip woocommerce.zip
#RUN unzip /var/www/html/wp-content/plugins/woocommerce.zip
# delete woocommerce.zip
#RUN rm -rf /var/www/html/wp-content/plugins/woocommerce.zip


# define( ‘DB_HOST’, ‘localhost:3306‘ );
#ARG db_host="localhost"
#ARG db_port="3306"
#ARG db_name="db"
#ARG db_user="admin"
#ARG db_pass="admin"



#WORKDIR /var/www/html/
# RUN cd /var/www/html/



# https://unix.stackexchange.com/questions/454220/how-to-assign-variable-and-use-sed-to-replace-contents-of-configuration-file-in
#ARG IPADDR
#RUN sed -i -r "s/IPADDR/${IPADDR}/g" /ipconf


# Working
# configure wordpress database

#RUN cp wp-config-sample.php wp-config.php
#RUN sed -i -r "s/'localhost'/'${db_host}:${db_port}'/g" wp-config.php
#RUN sed -i -r "s/'database_name_here'/'${db_name}'/g" wp-config.php
#RUN sed -i -r "s/'username_here'/'${db_user}'/g" wp-config.php
#RUN sed -i -r "s/'password_here'/'${db_pass}'/g" wp-config.php


# https://stackoverflow.com/questions/47942016/add-bind-mount-to-dockerfile-just-like-volume
# ENV DB_NAME="db"
# RUN cat wp-config.php | sed 's/database_name_here/"${DB_NAME}"/g' > wp-config.php



# https://askubuntu.com/questions/256013/apache-error-could-not-reliably-determine-the-servers-fully-qualified-domain-n
# RUN echo 'ServerName localhost' > /etc/apache2/apache2.conf

#RUN echo hostname -I
#RUN ls /var/www/html/


# WORKDIR /var/www/html/
EXPOSE 80
# EXPOSE 443

# By default, simply start apache.
CMD apachectl -D FOREGROUND