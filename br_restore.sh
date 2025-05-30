  #!/bin/bash

# Configuration
BACKUP_SERVER=$IP_BACKUP  # Adresse du serveur de sauvegarde
BACKUP_USER=$(hostname)                    # Utilisateur pour la connexion SSH
SSH_PORT="22"                           # Port SSH
SSH_KEY="$HOME/.ssh/id_ed25519"            # Chemin vers la clé   # Dossier distant de sauvegarde

# Fonction d'aide
usage() {
    echo "Usage: $0 /chemin/absolu/du/repertoire"
    exit 1
}

# Vérification des arguments
if [[ $# -ne 1 ]]; then
    usage
fi

TARGET_DIR="$1"

# Vérifie si le chemin est absolu
if [[ ! "$TARGET_DIR" =~ ^/ ]]; then
    echo "Erreur : le répertoire doit être un chemin absolu (commencer par /)"
    exit 1
fi

REMOTE_BACKUP_DIR=$TARGET_DIR
# Vérification et installation des dépendances
for cmd in ssh rsync; do
    if ! command -v "$cmd" >/dev/null; then
        echo "Installation de $cmd..."
        sudo apt install -y "$cmd"
    fi
done

# Activation des services (utile surtout sur le serveur)
sudo systemctl enable --now ssh

if systemctl is-active --quiet ssh; then
    echo "Le service SSH est actif"
fi

# Vérifie la connexion SSH
echo "Test de connexion SSH vers $BACKUP_USER@$BACKUP_SERVER..."
if ! ssh -i "$SSH_KEY" -p "$SSH_PORT" "$BACKUP_USER@$BACKUP_SERVER" "exit" >/dev/null 2>&1; then
    echo "Erreur : impossible de se connecter à $BACKUP_SERVER"
    exit 1
fi

# Vérifie que le répertoire distant de backup existe
if ! ssh -i "$SSH_KEY" -p "$SSH_PORT" "$BACKUP_USER@$BACKUP_SERVER" "test -f '$REMOTE_BACKUP_DIR'" >/dev/null 2>&1; then
    echo "Erreur : le répertoire distant $REMOTE_BACKUP_DIR n'existe pas."
    exit 1
fi

# Sauvegarde locale préalable si le dossier existe
#if [[ -d $TARGET_DIR" ]]; then
   # BACKUP_LOCAL=$(dirname $TARGET_DIR").bak.$(date '+%Y-%m-%d)
   # echo "Déplacement de $TARGET_DIR vers $BACKUP_LOCAL pour sauvegarde locale
  #  mv $TARGET_DIR "$BACKUP_LOCAL || {
  #      echo Erreur : impossible de déplacer le répertoire existant"
 #       exit 1
#    }
fi

# Création du répertoire parent local si nécessaire
PARENT_DIR=$(dirname "$TARGET_DIR")
if [[ ! -d "$PARENT_DIR" ]]; then
    mkdir -p -m 755 "$PARENT_DIR"
    echo "Création du répertoire parent : $PARENT_DIR"
fi

# Lancement de la sauvegarde
echo "Démarrage de la sauvegarde via rsync..."

if rsync -avz -e "ssh -p $SSH_PORT -i $SSH_KEY" "$BACKUP_LOCAL/" "$BACKUP_USER@$BACKUP_SERVER:$REMOTE_BACKUP_DIR/"; then
    echo "Sauvegarde réussie : $TARGET_DIR -> $REMOTE_BACKUP_DIR"
else
    echo "Échec de la sauvegarde"
    exit 1
fi

  