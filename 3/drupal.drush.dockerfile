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

#https://www.linode.com/docs/websites/cms/drupal/drush-drupal/how-to-install-drupal-using-drush-on-ubuntu-18-04/

# Install and run apache
#RUN apt-get install php-gd php-xml php-dom php-simplexml php-mbstring

RUN apt-get install -y apache2 php php-mysql php-mbstring php-xml php-gd wget curl unzip zip mysql-client && apt-get clean

RUN apt-get install perl nano -y

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


 

RUN echo "download" 
RUN apt-get install ca-certificates
RUN wget http://curl.haxx.se/ca/cacert.pem -O  cacert.crt --no-check-certificate
RUN ls /usr/local/share/ca-certificates/
RUN cp cacert.crt /usr/local/share/ca-certificates/cacert.crt
RUN update-ca-certificates

RUN php -m


#RUN trust -v anchor cacert.crt
# then logged into that VM and see it has adde
# https://raspberrytips.com/wordpress-on-raspberry-pi/
# RUN wget https://wordpress.org/latest.zip -O /var/www/html/wordpress.zip



# Installing composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e5325b19b381bfd88ce90a5ddb7823406b2a38cff6bb704b0acc289a09c8128d4a8ce2bbafcd1fcbdc38666422fe2806') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"



RUN a2enmod ssl

#RUN service apache2 restart

RUN mkdir /etc/apache2/ssl

#RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

# RUN echo	"<pre> \n" \ 
# 		"<IfModule modssl.c> \n" \ 
# 		"<VirtualHost _default:443> \n" \ 
# 		"ServerAdmin webmaster@localhost \n" \ 
# 		"DocumentRoot /var/www/html ErrorLog ${APACHELOGDIR}/error.log \n" \ 
# 		"CustomLog ${APACHELOGDIR}/access.log combined \n" \ 
# 		"SSLEngine on \n" \ 
# 		"SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key <FilesMatch “.(cgi|shtml|phtml|php)$”> SSLOptions +StdEnvVars </FilesMatch> <Directory /usr/lib/cgi-bin> SSLOptions +StdEnvVars </Directory> BrowserMatch “MSIE [2-6]” \ nokeepalive ssl-unclean-shutdown \ downgrade-1.0 force-response-1.0 BrowserMatch “MSIE [17-9]” ssl-unclean-shutdown </VirtualHost> </IfModule> </pre>" > /etc/apache2/sites-available/default-ssl.conf

#RUN a2ensite default-ssl.conf
RUN service apache2 restart


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
#RUN composer update
#RUN composer create-project drupal/recommended-projects

#RUN composer config --global disable-tls true
#RUN composer config --global secure-http false
#RUN composer diag
#RUN composer create-project drupal/recommended-project my_site_name_dir


#RUN composer create-project drupal-composer/drupal-project:8.x-dev drupal-composer-build --no-check-certificate
RUN composer global require drush/drush

#RUN composer global require webflo/drush-shim

RUN composer update drupal/core –with-dependencies
RUN composer update
RUN composer install

RUN composer require --dev drush/drush
RUN ./vendor/bin/drush --version
#RUN ~/.bashrc


#RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar
#RUN chmod +x drush.phar
#RUN mv drush.phar /usr/local/bin/drush
#RUN ./vendor/bin/drush si standard --db-url=mysql://admin:admin@db/mydb -y
#--site-name=example.com
#RUN drush si standard --db-url=mysql://username:password@localhost/databasename --site-name=example.com

RUN usermod -a -G www-data root
#RUN chown -R -f www-data:www-data /var/www/html

RUN	chown www-data:www-data /var/www/html/ -Rf

RUN a2enmod rewrite

#RUN sed -i -r "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

# nano  /etc/apache2/sites-available/000-default.conf

# nano /etc/apache2/sites-available/default-ssl.conf

# RUN echo "<Directory /var/www/html/> \n" \ 
# 		"    Options Indexes FollowSymLinks \n" \ 
# 		"    AllowOverride All \n" \ 
# 		"    Require all granted \n" \ 
# 		"      RewriteEngine on \n" \ 
# 		"      RewriteBase / \n" \ 
# 		"      RewriteCond %{REQUEST_FILENAME} !-f \n" \ 
# 		"      RewriteCond %{REQUEST_FILENAME} !-d \n" \ 
# 		"      RewriteRule ^(.*)$ index.php?q=$1 [L,QSA] \n" \ 
# 		"</Directory>" > 000-default.conf.gg


#RUN sed -i -r "s/AllowOverride None/AllowOverride All/g" /etc/apache2/sites-available/000-default.conf

#RUN mv 000-default.conf /etc/apache2/sites-available/000-default.conf
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

#RUN sed -E "s/\$databases = [];/\asdasd/" /var/www/html/sites/default/settings.php
#RUN sed -i "/${PWD//\//\\/}/a Hello World" /var/www/html/sites/default/settings.php
#nano /var/www/html/sites/default/settings.php
#RUN sed -e "s/\$databases = [];\([^ ,]*\)/'variable_\1'/g"  /var/www/html/sites/default/settings.php
#RUN STR="\$databases = [];"
#RUN echo $STR   
#RUN grep "\$databases = [];/" /var/www/html/sites/default/settings.php


#https://stackoverflow.com/questions/41570993/using-sed-to-replace-variable-name-and-its-value/41575985
#$_PATHROOT = '../../../../';
#define('_PATHROOT', '../../../../');
#sed -ri "s/^[$]_PATHROOT = '(([.][.]\/)+)';$/define('_PATHROOT', '\1');/" FILEPATH

#RUN sed -ri "s/[$]databases = [];/define('_PATHROOT', '\1');/" /var/www/html/sites/default/settings.php
#https://unix.stackexchange.com/questions/183845/how-do-i-replace-a-string-with-dollar-sign-in-sed/183848


RUN ORIGINAL='File.Config=\$(config, 8, 12)'
RUN MODIFIED='File.Config=\#(config, 8, 12)'
RUN Var1='\$databases = []'
RUN Var2='\$dotabases = []'


#RUN grep '\$databases' /var/www/html/sites/default/settings.php
#RUN cat /var/www/html/sites/default/settings.php | grep "\$databases = []"
#https://stackoverflow.com/questions/48780463/how-to-replace-a-text-string-with-dollar-sign-in-linux
# el chabon que hizo este pos me re salvo de perder la cordura
#RUN sed -i s/databases/\\\$databases\ gg/g /var/www/html/sites/default/settings.php
#RUN sed -i s/databases/\\\$databases\ \=\ \[]\/g /var/www/html/sites/default/settings.php
#Working
#RUN sed -i s/\\\$databases\ \=\ \\\[]\/\\\$dotabases\ \=\ \[]\/g /var/www/html/sites/default/settings.php
#Working
#RUN sed -i s/\\\$databases\ \=\ \\\[]\/\\\$databases\ \=\ \\\[]\/g /var/www/html/sites/default/settings.php
#RUN sed -i s/\\\$databases\ \=\ \\\[]\/\\\$databases['default']['default']\ \=\ \['database'\ \=\>\ \\\]\/g /var/www/html/sites/default/settings.php

#WORKING AJUA
RUN sed -i s/\\\$databases\ \=\ \\\[]\/\\\$databases["'default'"]["'default'"]\ \=\ \["'database'"\ \=\>\ "'mydb'","'username'"\ \=\>\ "'admin'","'password'"\ \=\>\ "'admin'","'host'"\ \=\>\ "'db'","'port'"\ \=\>\ "'3306'","'driver'"\ \=\>\ "'mysql'","'prefix'"\ \=\>\ "'dp_'","'collation'"\ \=\>\ "'utf8mb4_general_ci'",\]/g /var/www/html/sites/default/settings.php

#  nano /var/www/html/sites/default/settings.php

#RUN sed -i s/\\\$databases\ \=\ \\\[]\/\\\$databases['default']['default']\/g /var/www/html/sites/default/settings.php

#https://linuxhint.com/bash_sed_examples/
#RUN rm /var/www/html/sites/default/settings.php
#RUN echo "\$databases['default']['default'] = ['database' => 'mydb','username' => 'admin','password' => 'admin','host' => 'db','port' => '3306','driver' => 'mysql','prefix' => 'dp_','collation' => 'utf8mb4_general_ci',];" > /var/www/html/sites/default/settings.php

# RUN echo "\$databases['default']['default'] = [ \n" \ 
# 		"          'database' => 'databasename', \n" \ 
# 		"          'username' => 'sqlusername', \n" \ 
# 		"          'password' => 'sqlpassword', \n" \ 
# 		"          'host' => 'localhost', \n" \ 
# 		"          'port' => '3306', \n" \ 
# 		"          'driver' => 'mysql', \n" \ 
# 		"          'prefix' => '', \n" \ 
# 		"          'collation' => 'utf8mb4_general_ci'," > /var/www/html/sites/default/settings.php
#RUN sed -i -e '$a\$databases['default']['default'] = ['database' => 'mydb','username' => 'admin','password' => 'admin','host' => 'db','port' => '3306','driver' => 'mysql','prefix' => 'dp_','collation' => 'utf8mb4_general_ci',];' /var/www/html/sites/default/settings.php

RUN cat /var/www/html/sites/default/settings.php
#RUN sed 's/$STR/GG/g' /var/www/html/sites/default/settings.php

#RUN cat /var/www/html/sites/default/settings.php
#sed -e "s/\$variable_\([^ ,]*\)/'variable_\1'/g" myscript.php

#RUN sed -i -r '/$databases = [];/c\$databases['default']['default'] = ['database' => 'mydb','username' => 'admin','password' => 'admin','host' => 'db','port' => '3306','driver' => 'mysql','prefix' => 'dp_','collation' => 'utf8mb4_general_ci',];' sites/default/settings.php
#RUN cat sites/default/settings.php
#RUN sed -i -r "s/AllowOverride None/AllowOverride All/g" /etc/apache2/sites-available/000-default.conf
RUN sed -i -r "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf



#RUN sed -i "15i $databases['default']['default'] = ['database' => 'mydb','username' => 'admin','password' => 'admin','host' => 'db','port' => '3306','driver' => 'mysql','prefix' => 'dp_','collation' => 'utf8mb4_general_ci',];" /var/www/html/sites/default/settings.php
#RUN perl -0777 -pe 's/(.*<Directory '/var/www/html'>[^\n]*)/$1\nAllowOverride All/s' /etc/apache2/sites-available/000-default.conf

# RUN find /etc -name httpd* -or find /etc -name apache2* 

#RUN apache2ctl -M | grep -i write


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
ARG db_host="localhost"
ARG db_port="3306"
ARG db_name="db"
ARG db_user="admin"
ARG db_pass="admin"
ARG db_pref="dp_"
ARG db_coll="utf8mb4_general_ci"

RUN sed -i s/\\\$databases\ \=\ \\\[]\/\\\$databases["'default'"]["'default'"]\ \=\ \["'database'"\ \=\>\ "'${db_name}'","'username'"\ \=\>\ "'${db_user}'","'password'"\ \=\>\ "'${db_pass}'","'host'"\ \=\>\ "'${db_host}'","'port'"\ \=\>\ "'${db_port}'","'driver'"\ \=\>\ "'mysql'","'prefix'"\ \=\>\ "'${db_pref}'","'collation'"\ \=\>\ "'${db_coll}'",\]/g /var/www/html/sites/default/settings.php

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