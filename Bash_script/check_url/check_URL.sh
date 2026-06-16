#!/bin/bash
clear

LISTA=$1
LOG_FILE="/var/log/status_url.log"

mkdir -p /tmp/head-check/{Error/{cliente,servidor},ok}

ANT_IFS=$IFS
IFS=$'\n'
for LINEA in $(cat $LISTA | grep -v ^#)
do
  DOMINIO=$(echo $LINEA | awk '{print $1}')
  URL=$(echo $LINEA | awk '{print $2}')
  STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  LOGLINE="$TIMESTAMP - Code:$STATUS_CODE - URL:$URL"

  echo "$LOGLINE" | sudo tee -a "$LOG_FILE"

  if [[ $STATUS_CODE -eq 200 ]]; then
    echo "$LOGLINE" >> /tmp/head-check/ok/$DOMINIO.log
  elif [[ $STATUS_CODE -ge 400 && $STATUS_CODE -lt 500 ]]; then
    echo "$LOGLINE" >> /tmp/head-check/Error/cliente/$DOMINIO.log
  elif [[ $STATUS_CODE -ge 500 && $STATUS_CODE -lt 600 ]]; then
    echo "$LOGLINE" >> /tmp/head-check/Error/servidor/$DOMINIO.log
  fi
done
IFS=$ANT_IFS
