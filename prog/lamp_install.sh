#!/bin/bash

pacman --noconfirm -Syu apache php php-apache php-imap mysql

mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

systemctl start httpd mysqld

mysql_secure_installation

echo "IncludeOptional conf/sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
echo "IncludeOptional conf/mods-enabled/*.conf" >> /etc/httpd/conf/httpd.conf
echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf
mkdir /etc/httpd/conf/sites-available
mkdir /etc/httpd/conf/sites-enabled
mkdir /etc/httpd/conf/mods-enabled

sed -i 's/^LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/g' /etc/httpd/conf/httpd.conf
sed -i 's/^#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/g' /etc/httpd/conf/httpd.conf
sed -i 's/^#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/g' /etc/httpd/conf/httpd.conf

systemctl restart httpd

cat >> /usr/local/bin/a2ensite << 'EOF'
#!/bin/bash
if test -d /etc/httpd/conf/sites-available && test -d /etc/httpd/conf/sites-enabled  ; then
echo "-------------------------------"
else
mkdir /etc/httpd/conf/sites-available
mkdir /etc/httpd/conf/sites-enabled
fi

avail=/etc/httpd/conf/sites-available/$1.conf
enabled=/etc/httpd/conf/sites-enabled
site=`ls /etc/httpd/conf/sites-available/`

if [ "$#" != "1" ]; then
        echo "Use script: n2ensite virtual_site"
        echo -e "\nAvailable virtual hosts:\n$site"
        exit 0
else
if test -e $avail; then
sudo ln -s $avail $enabled
else
echo -e "$avail virtual host does not exist! Please create one!\n$site"
exit 0
fi
if test -e $enabled/$1.conf; then
echo "Success!! Now restart Apache server: sudo systemctl restart httpd"
else
echo  -e "Virtual host $avail does not exist!\nPlease see avail virtual hosts:\n$site"
exit 0
fi
fi
EOF
chmod +x /usr/local/bin/a2ensite /usr/local/bin/a2ensite

cat >> /usr/local/bin/a2dissite << 'EOF'
#!/bin/bash
avail=/etc/httpd/conf/sites-enabled/$1.conf
enabled=/etc/httpd/conf/sites-enabled
site=`ls /etc/httpd/conf/sites-enabled`

if [ "$#" != "1" ]; then
        echo "Use script: n2dissite virtual_site"
        echo -e "\nAvailable virtual hosts: \n$site"
        exit 0
else
if test -e $avail; then
sudo rm  $avail
else
echo -e "$avail virtual host does not exist! Exiting"
exit 0
fi
if test -e $enabled/$1.conf; then
echo "Error!! Could not remove $avail virtual host!"
else
echo  -e "Success! $avail has been removed!\nsudo systemctl restart httpd"
exit 0
fi
fi
EOF
chmod +x /usr/local/bin/a2ensite /usr/local/bin/a2dissite



echo "# Мои настройки PHP!!!" >> /etc/httpd/conf/extra/php.conf
echo "LoadModule php_module modules/libphp.so" >> /etc/httpd/conf/extra/php.conf
echo "AddHandler php-script .php" >> /etc/httpd/conf/extra/php.conf
echo "Include conf/extra/php_module.conf" >> /etc/httpd/conf/extra/php.conf


ln -s /etc/httpd/conf/extra/php.conf /etc/httpd/conf/mods-enabled/php.conf

pacman --noconfirm -S phpmyadmin

sed -i 's/^;extension=bz2/extension=bz2/g' /etc/php/php.ini
sed -i 's/^;extension=iconv/extension=iconv/g' /etc/php/php.ini
sed -i 's/^;extension=imap/extension=imap/g' /etc/php/php.ini
sed -i 's/^;extension=mysqli/extension=mysqli/g' /etc/php/php.ini
sed -i 's/^;extension=pdo_mysql/extension=pdo_mysql/g' /etc/php/php.ini
sed -i 's/^;extension=zip/extension=zip/g' /etc/php/php.ini
sed -i 's/^;session.save_path = "\/tmp"/session.save_path = "\/tmp"/g' /etc/php/php.ini

cat >> /etc/webapps/phpmyadmin/config.inc.php << 'EOF'
$cfg['TempDir'] = '/tmp';
EOF

cat >> /etc/webapps/phpmyadmin/config.inc.php << 'EOF'
$cfg['blowfish_secret'] = 'kjLGJ8g;Hj3mlHy+Gd~FE3mN{gIATs^1lX+T=KVYv{ubK*U0V';
EOF

cat << phpmyadmin > /etc/httpd/conf/sites-available/phpmyadmin.conf
Alias /phpmyadmin "/usr/share/webapps/phpMyAdmin"
<Directory "/usr/share/webapps/phpMyAdmin">
  DirectoryIndex index.html index.php
  AllowOverride All
  Options FollowSymlinks
  Require all granted
</Directory>
phpmyadmin
a2ensite phpmyadmin

systemctl restart httpd mysqld
