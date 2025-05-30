#!/bin/bash

#Prendre l'ip du client

if [[ -z $2 ]]; then
  usage    
fi
	

IPCLIENT=$1
USERNAME=$2

TMPDIR=$(mktemp -d)
IPSERVER=$(ip -o -4 addr list enp0s3|awk '{print $4}'|cut -d"/" -f1)

#Connection client ssh + recuperation du hostname + generation cle ssh


ssh "$USERNAME@$IPCLIENT" " 
  #Renseigner ip Server
  echo 'export IP_BACKUP="$IPSERVER"' >> ~/.bashrc
   #Génère la clé si besoin
  if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
  fi
   #Affiche le hostname et la clé publique
  hostname
  
  cat ~/.ssh/id_ed25519.pub
  
" > "$TMPDIR/clientinfo.txt"

HOSTNAME=$(head -n 1 "$TMPDIR/clientinfo.txt") #Prend la premiere ligne du fichier
PUBKEY=$(tail -n +2 "$TMPDIR/clientinfo.txt") #Prend le reste du fichier a partir de la dexieme ligne

if [[ -z "$HOSTNAME" ]] || [[ -z "$PUBKEY" ]]; then
  echo "Erreur : récupération des infos client échouée."
  exit 1
fi



useradd -m "$HOSTNAME"  2>/dev/null

mkdir -p /home/$HOSTNAME/.ssh
chown $HOSTNAME:$HOSTNAME /home/$HOSTNAME/.ssh 
chmod 700 /HOSTNAME/.ssh

echo "$PUBKEY" >> /home/$HOSTNAME/.ssh/authorized_keys
sudo chown $HOSTNAME:$HOSTNAME /home/$HOSTNAME/.ssh/authorized_keys
sudo chmod 600 /home/$HOSTNAME/.ssh/authorized_keys


rm -fr "$TMPDIR"

