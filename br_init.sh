#!/bin/bash

#Prendre l'ip du client

if [[ -z $2 ]]; then
  usage    
fi

IPCLIENT=$1
USERNAME=$2

TMPDIR=$(mktemp -d)

#Connection client ssh + recuperation du hostname + generation cle ssh

ssh "$USERNAME@$IPCLIENT" ' 
  # Génère la clé si besoin
  if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
  fi
  # Affiche le hostname et la clé publique
  hostname
  
  cat ~/.ssh/id_ed25519.pub
  
' > "$TMPDIR/clientinfo.txt"

HOSTNAME=$(head -n 1 "$TMPDIR/clientinfo.txt") #Prend la premiere ligne du fichier
PUBKEY=$(tail -n +2 "$TMPDIR/clientinfo.txt") #Prend le reste du fichier a partir de la dexieme ligne

if [ -z "$HOSTNAME" ] || [ -z "$PUBKEY" ]; then
  echo "Erreur : récupération des infos client échouée."
  exit 1
fi

