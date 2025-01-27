#!/bin/bash

## Dialog function
boot_dialog() {
	DIALOG_RESULT=$(whiptail --clear --backtitle " ADD SERVER" "$@" 3>&1 1>&2 2>&3)
	DIALOG_CODE=$?
	if [[ $DIALOG_CODE -eq 1 ]]; then
	   boot_dialog --title "Cancelled" --msgbox "\nScript was cancelled at your request." 10 60
	   exit 0
	fi
}

## DirName
boot_dialog --title "Disk" --inputbox "\\nПожалуйста, Укажите полный путь к папке c WEB SERVER.\nНапример /run/media/notebook/MEDIA/project_www\n\n" 10 60 /run/media/notebook/MEDIA/project_www
dirname=$DIALOG_RESULT

## WebName
boot_dialog --title "Disk" --inputbox "\\nПожалуйста, Укажите название WEB сайта.\nНапример shop.loc\n\n" 10 60
webname=$DIALOG_RESULT

cat << localpc > /etc/httpd/conf/sites-available/"$webname".conf
<VirtualHost *:80>
    DocumentRoot "$dirname/$webname"
    ServerName $webname
    ServerAlias www.$webname.loc
    ServerAdmin postmaster@$webname
    ErrorLog "/var/log/httpd/$webname-error_log"
    TransferLog "/var/log/httpd/$webname-access_log"
	
	<Directory />
		Options +Indexes +FollowSymLinks +ExecCGI
		AllowOverride All
		Order deny,allow
		Allow from all
		Require all granted
	</Directory>
</VirtualHost>
localpc

{ echo ""
  echo "127.0.0.1 $webname"
  echo "127.0.0.1 www.$webname.loc"
} >> /etc/hosts

mkdir -p "$dirname"
mkdir -p "$dirname"/"$webname"
mkdir -p "$dirname"/"$webname"/css
echo ""> "$dirname"/"$webname"/css/style.css
mkdir -p "$dirname"/"$webname"/images
mkdir -p "$dirname"/"$webname"/js
mkdir -p "$dirname"/"$webname"/templates

cat >> "$dirname"/"$webname"/.htaccess << 'EOF'
AddDefaultCharset utf-8
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php
EOF

cat >> "$dirname"/"$webname"/info.php << 'EOF'
<?php" >
"phpinfo();"
EOF

cat >> "$dirname"/"$webname"/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
</head>
<body>
Server работает !!!
</body>
</html>
EOF

sudo chown -R "$USER":users "$dirname"
sudo chmod -R 777 "$dirname"

sudo a2ensite "$webname"

sudo systemctl restart httpd mysqld

if [[ $DIALOG_CODE -eq 1 ]]; then
	boot_dialog --title "Cancelled" --msgbox "\nScript был отменен по вашему запросу." 10 60
  exit 0
fi

apachectl configtest

#### The end ####
printf "Скрипт завершил свою работу.\n"
