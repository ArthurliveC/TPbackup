#!usr/bin/bash

BACKUP_SERVER="your-backup-server.com"  #Adressse du serveur de sauvegarde
BACKUP_user="backup" 			#Utilisateur pour la connexion SSH
BACKUP_PATH="/backups"			#Répertoire racine des sauvegardes sur le serveur
SSH_PORT="22"				#Chemin vers la clé SSH



if [[ $# -e ]]; then
	usage
fi

TARGET_DIR="$1"

# Vérification que le répertoire a un chemin

	# The operator =~ permet de comparer le coté droit au côté gauche

if [[ ! "$TARGET_DIR" =~ ^/ ]] &&  echo "Le répertoire n'est pas un chemin absolu car il ne commence pas par /"
fi


# Vérification des dépendances (ssh, synchro client-bkp) 

if [[ ! command -V SSH >/dev/null ]]; then

	apt install openssh-client -y
	echo "ssh est installé"
fi
	
systemctl enable --now ssh

if [[ systemctl is-active ssh]]; then
	echo "Le service SSH est actif"
fi


if [[ ! command -V rsync >/dev/null ]]; then

	apt install rsync -y
	echo "rsync est installé"
fi

systemctl enable --now rsync

if [[ systemctl is-active rsync]]; then
	echo "Le service rsync est actif"
fi


# Création du chemin de sauvegarde

HOSTNAME=$(hostname)
REMOTE_BACKUP_DIR="$BACKUP_PATH/$HOSTNAME$TARGET_DIR"

