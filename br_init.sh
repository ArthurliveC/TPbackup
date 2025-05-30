#!/bin/bash

#Prendre l'ip du client

if [[ -z $2 ]]; then
  usage    
fi

IPCLIENT=$1
USERNAME=$2

#Connection client ssh + recuperation du hostname

HOSTNAME=$(ssh -T "$USERNAMR@$IPCLIENT" "bash -c 'hostname'")
if [ -z "$HOSTNAME" ]; then
  echo "Erreur : impossible de récupérer le hostname du client ($USERNAME)."
  exit 1
fi