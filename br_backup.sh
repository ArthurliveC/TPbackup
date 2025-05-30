#!/bin/bash


if [[ -z $1 ]]; then
  usage    
fi

DIRBACKUP=$1
NOMARCHIVE=$(basename $1)
HOSTNAME=$(hostname)

#Verification de la presence du repertoire
if [[ ! -d "$DIRBACKUP" ]]; then
	echo "Erreur: Ce repertoire n'existe pas."
	exit 1
fi

#Verification de la presence du la variable
if [[ ! "$ip_backup" ]]; then
	echo "Erreur: Cette variable n'existe pas."
	exit 1
fi

tar -czf ~/$NOMARCHIVE.tar.gz $DIRBACKUP 



DIRBACKUP_SRV="/home/$HOSTNAME/$(dirname "$DIRBACKUP")"
ssh "$HOSTNAME@$IP_BACKUP" "mkdir -p 'DIRBACKUP_SRV'"

scp "$NOMARCHIVE.tar.gz.enc" "$HOSTNAME@$IP_BACKUP:$DIRBACKUP_SRV/$NOMARCHIVE.tar.gz.enc"

rm -f "$NOMARCHIVE.tar.gz.enc"

echo "Backup de $DIRBACKUP terminé et envoyé sur le serveur backup $IP_BACKUP !"