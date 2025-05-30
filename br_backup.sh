#!/bin/bash


if [[ -z $1 ]]; then
  usage    
fi

DIRBACKUP=$1
NOMARCHIVE=$(basename $1)
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

