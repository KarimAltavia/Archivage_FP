#!/bin/bash

#Ce script Bash est conçu pour automatiser la sauvegarde de données pour un client 
#spécifique. L'utilisateur est invité à saisir le nom du client, puis le script 
#vérifie l'existence des dossiers source et cible, gère un fichier journal 
#pour enregistrer les opérations, vérifie les autorisations d'accès, 
#déplace le contenu du dossier cible vers le dossier source 
#et copie le contenu du dossier source vers un dossier d'archives. 
#Il effectue ces opérations tout en journalisant chaque étape pour un suivi complet 
#des actions effectuées.


# Demander le nom du client à sauvegarder
read -p "Quel client souhaitez-vous sauvegarder ? " client_name

# # Chemins des dossiers basés sur la réponse de l'utilisateur
# source_dir="/mnt/prod/shares/$client_name/FRANCE/00_A_ARCHIVER_ONLINE/"
# target_dir="/mnt/prod/shares/ALTFRSE/ALTFRSE_SORTIE_FLUX/BIODERMA/"
# archive_dir="/mnt/prod/shares/ARCHIVES-2ANS/FRANCE/BIODERMA/"


# Chemins des dossiers basés sur la réponse de l'utilisateur
source_dir="/Users/k.bachekour/$client_name/A_ARCHIVER_ONLINE"
target_dir="/Users/k.bachekour/$client_name/ALTFRSE_SORTIE_FLUX"
archive_dir="/Users/k.bachekour/$client_name/ARCHIVES-2ANS"

# Vérification de l'existence du dossier source
if [ ! -d "$source_dir" ]; then
    echo "Le dossier source n'existe pas : $source_dir"
    exit 1
fi

# Vérification de l'existence du dossier cible
if [ ! -d "$target_dir" ]; then
    echo "Le dossier cible n'existe pas : $target_dir"
    exit 1
fi

# Chemin du répertoire du fichier journal
log_dir="$archive_dir/$client_name/log"

# Vérifier si le répertoire du fichier journal existe, sinon le créer
if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
fi

# Définir un fichier journal pour enregistrer les opérations
log_file="$log_dir/move_script.log"

# Fonction pour journaliser un message
log() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$log_file"
}

# Vérification des autorisations d'accès en lecture et écriture
if [ ! -r "$source_dir" ] || [ ! -w "$source_dir" ]; then
    log "Vous n'avez pas les autorisations nécessaires sur le dossier source : $source_dir"
    exit 1
fi

if [ ! -r "$target_dir" ] || [ ! -w "$target_dir" ]; then
    log "Vous n'avez pas les autorisations nécessaires sur le dossier cible : $target_dir"
    exit 1
fi

# Vérification si le dossier source est vide
if [ "$(find "$source_dir" -maxdepth 0 -empty)" ]; then
    log "Aucun dossier à sauvegarder dans le dossier source : $source_dir"
else
    # Parcourir les dossiers dans le dossier source
    for folder in "$source_dir"/*; do
        if [ -d "$folder" ]; then
            folder_name=$(basename "$folder")
            # Vérifier si le dossier avec le même nom existe dans le dossier cible
            if [ -d "$target_dir/$folder_name" ]; then
                log "Le dossier $folder_name existe dans le dossier cible."
                # Déplacer le contenu du dossier cible dans le dossier source renommé en "SORTIE_FLUX"
                if mv "$target_dir/$folder_name" "$source_dir/$folder_name/SORTIE_FLUX"; then
                    log "Le contenu du dossier $folder_name a été déplacé avec succès dans SORTIE_FLUX."
                else
                    log "Erreur lors du déplacement du contenu du dossier $folder_name dans SORTIE_FLUX."
                fi
            else
                log "Le dossier $folder_name n'existe pas dans le dossier cible."
            fi
        fi
    done

    # Copier le contenu du dossier source vers le dossier d'archive
    rsync -a --remove-source-files "$source_dir/" "$archive_dir/$client_name/"

    log "Le contenu du dossier source a été copié avec succès dans ARCHIVES-2ANS."
fi

log "Opérations terminées."



