#!/bin/bash
clear
LISTA=$1
USUARIO_CLAVE=$2
HASH=$(sudo grep $USUARIO_CLAVE /etc/shadow | awk -F ':' '{print $2}')
ANT_IFS=$IFS
IFS=$'\n'
for LINEA in $(cat $LISTA | grep -v ^#)
do
  USUARIO=$(echo $LINEA | awk -F ',' '{print $1}')
  GRUPO=$(echo $LINEA | awk -F ',' '{print $2}')
  HOME=$(echo $LINEA | awk -F ',' '{print $3}')
  sudo groupadd $GRUPO 2>/dev/null
  sudo useradd -m -s /bin/bash -g $GRUPO -d $HOME -p $HASH $USUARIO
done
IFS=$ANT_IFS
