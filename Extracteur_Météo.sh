#!/bin/bash

#Ce script à pour but de récupérer les donners du site internet et de les formater de sorte à voir la météo 
#d'aujourdh'ui et de demain. 

if [ $# -eq 0 ]; then
    echo "Usage: $0 <ville>"
    exit 1
fi 
#je m'assure du bon appel de mon scritp "./Extracteur_meteo.sh <ville>"

VILLE=$1
# la ville a pour valeur celle faite à l'appel ./Extracteur_Météo.sh <Nom_Ville>

DIR="/Users/mathieu/Desktop/MATHIEU/UT3/1er_SEMESTRE/CONFIGUATION_POST_DE_TRAVAIL/Projet/git_projets/projet_Poste3_gr4/" 
# ce chemin n'est valable que pour moi il faudra le changer pour vous
# c'est le chemin vers l'endroit ou se trouve mon répertoire de travail
DATA="${DIR}info_meteo.txt"

curl -s "wttr.in/${VILLE}?format=j2" -o "$DATA"
#je vais chercher en ligne les données de la ville, je les mets en format json compact pour un meilleur traitement 
#puis je les assignent à $DATA
