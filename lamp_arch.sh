#!/bin/bash

## Функция меню диалога
boot_dialog() {
    DIALOG_RESULT=$(whiptail --clear --backtitle "INSTALL LAMP Arch Linux & Manjaro Linux" "$@" 3>&1 1>&2 2>&3)
    DIALOG_CODE=$?
    if [[ $DIALOG_CODE -eq 1 ]]; then
        boot_dialog --title "Cancelled" --msgbox "\nScript was cancelled at your request." 10 60
        exit 0
    fi
}

# Меню установки программ
boot_dialog --notags --title "INSTALL LAMP" --checklist "Выберите нужное действие." 10 60 4 \
    "lampinstall" "lamp_install.sh - установка LAMP" OFF \
    "lampdel" "lamp_del.sh - удаление LAMP" OFF \
    "serveradd" "server_add.sh - добавление нового WEB сервера" OFF \
    "serverdel" "server_del.sh - удаление WEB сервера" OFF
    progs="$DIALOG_RESULT"

## Отмена установки
if [[ $DIALOG_CODE -eq 1 ]]; then
    boot_dialog --title "Cancelled" --msgbox "\nScript был отменен по вашему запросу." 10 60
    exit 0
fi

### Установка LAMP & Server для Arch linux и Manjaro ###
sudo pacman -Syyuu
for action in $progs; do
    case "$action" in
        '"lampinstall"')
            curl -fLo ${HOME}/temp/lamp_install.sh --create-dirs https://raw.githubusercontent.com/ShvetsRoman/lamp/main/prog/lamp_install.sh
            sudo sh ${HOME}/temp/lamp_install.sh
            ;;
        '"lampdel"')
            curl -fLo ${HOME}/temp/lamp_del.sh --create-dirs https://raw.githubusercontent.com/ShvetsRoman/lamp/main/prog/lamp_del.sh
            sudo sh ${HOME}/temp/lamp_del.sh
            ;;
        '"serveradd"')
            curl -fLo ${HOME}/temp/server_add.sh --create-dirs https://raw.githubusercontent.com/ShvetsRoman/lamp/main/prog/server_add.sh
            sudo sh ${HOME}/temp/server_add.sh
            ;;
        '"serverdel"')
            curl -fLo ${HOME}/temp/server_del.sh --create-dirs https://raw.githubusercontent.com/ShvetsRoman/lamp/main/prog/server_del.sh
            sudo sh ${HOME}/temp/server_del.sh
            ;;
    esac
done

# Если папка ${HOME}/temp есть, тогда удаляем.
if [[ -e ${HOME}/temp ]]; then
    rm -r ${HOME}/temp
fi
