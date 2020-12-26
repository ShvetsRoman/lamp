#!/bin/bash

pacman --noconfirm -Rns phpmyadmin php-imap php-apache php apache
#pacman --noconfirm -Rns mysql
rm -r /etc/httpd/
rm /usr/local/bin/a2ensite
rm /usr/local/bin/a2dissite
rm -r /etc/php/
rm -r /usr/share/webapps/
