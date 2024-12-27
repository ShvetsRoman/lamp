#!/bin/bash

## Dialog function
boot_dialog() {
	DIALOG_RESULT=$(whiptail --clear --backtitle " DEL SERVER" "$@" 3>&1 1>&2 2>&3)
	DIALOG_CODE=$?
	if [[ $DIALOG_CODE -eq 1 ]]; then
	   boot_dialog --title "Cancelled" --msgbox "\nScript was cancelled at your request." 10 60
	   exit 0
	fi
}

## DirName
boot_dialog --title "Disk" --inputbox "\\nПожалуйста, Укажите полный путь к папке c WEB SERVER для удаления.\nНапример /run/media/notebook/MEDIA/www\n\n" 10 60 /run/media/notebook/MEDIA/www/
dirname=$DIALOG_RESULT

## WebName
boot_dialog --title "Disk" --inputbox "\\nПожалуйста, Укажите название WEB сайта для удаления.\nНапример shop.local\n\n" 10 60
webname=$DIALOG_RESULT

rm /etc/httpd/conf/sites-available/"$webname".conf
rm /etc/httpd/conf/sites-enabled/"$webname".conf

sed -i 's/^127.0.0.1 '"$webname"'//g' /etc/hosts
sed -i 's/^127.0.0.1 www.'"$webname"'//g' /etc/hosts

rm -rf "${dirname:?}"/

if [[ $DIALOG_CODE -eq 1 ]]; then
	boot_dialog --title "Cancelled" --msgbox "\nScript был отменен по вашему запросу." 10 60
  exit 0
fi

#### The end ####
printf "Скрипт завершил свою работу.\n"
