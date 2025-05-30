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
echo "Sauvegarde de: $TARGET_DIR"
echo "Depuis: $BACKUP_USER@$BACKUP_SERVER:$REMOTE_BACKUP_DIR"


# Vérification connexion SHH 

echo "Test de connexion au serveur"

if [[ ! ssh -p "$SSH_PORT" "$REMOTE_BACKUP_DIR" >/dev/null ]]; then
    echo " Impossible de se connecter à BACKUP_SERVER"
fi


# Vérification si la sauvegarde existe

echo "Vérification si la sauvegarde existe"

if [[ ! ssh -p "$SSH_PORT" "$BACKUP_USER@$BACKUP_SERVER" "$REMOTE_BACKUP_DIR" >/dev/null ]]; then
    echo " Sauvegarde introuvable:REMOTE_BACKUP_DIR"
fi

# Vérification de la sauvegarde locale sur le répertoire existant

if [[ -d "$TARGET_DIR" ]]; then
    BACKUP_LOCAL="$(TARGET_DIR)".bak.$(date '+%Y-%m-%d')"     # $(date '+%Y-%m-%d') --> horodatage avec date uniquement
    echo "Sauvegarde du répertoire qui existe vers $BACKUP_LOCAL"

    if [[ ! sudo mv "$TARGET_DIR" "$BACKUP_LOCAL" ]]; then
        echo "Impossible de sauvegarder sur le répertoire existant"
    fi 
fi

# Création du répertoire parent

PARENT_DIR=$(dirname "$TARGET_DIR")

if [[ ! -d "$PARENT_DIR" ]]; then    
    sudo mkdir -m 755 -p "$PARENT_DIR" 
    echo " $PARENT_DIR créé"
fi

# Sauvegarde

echo "Début de la sauvegarde"

#-a : archive (préserve structure, permissions, liens, etc.)
#-v : mode verbeux (affiche les fichiers transférés)
#-z : compression (réduit la bande passante)

if [[ rsync -avz -e "ssh -p $SSH_PORT" -i "$SSH_KEY" "$BACHUP_LOCAL" "$REMOTE_BACKUP_DIR" ]]; then
    echo "Succès de la sauvegarde"
    echo " Répertoire sauvegardé $TARGET_DIR"
else
    echo "Echec de la sauvegarde"
fi
