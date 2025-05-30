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

#Créer le dossier .keys s'il n'existe pas
if [[ ! -d ~/.keys ]]; then
	mkdir -p  ~/.keys
fi	

#Générer les clés si elles n'existent pas
if [[ ! -f ~/.keys/key.hex ]] || [[ ! -f ~/.keys/iv.hex ]]; then
	openssl rand -hex 32 > ~/.keys/key.hex
       	openssl rand -hex 16 > ~/.keys/iv.hex
fi

tar -czf ~/$NOMARCHIVE.tar.gz $DIRBACKUP | openssl enc -aes-256-cbc -k $(cat ~/.keys/key.hex) -iv $(cat ~/.keys/iv.hex) -in ~/$NOMARCHIVE.tar.gz -out ~/$NOMARCHIVE.tar.gz.enc 


