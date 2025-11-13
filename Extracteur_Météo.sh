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

DATA="info_meteo.txt"
>"$DATA"
#Nom du fichier temporaire servant a stocker les données brute du site,  si il existe déja, on le vide ou alors on le crée.

curl -s "wttr.in/${VILLE}?format=j2" -o "$DATA"
#je vais chercher en ligne les données de la ville, je les mets en format json compact pour un meilleur traitement 
#puis je les assignent à $DATA


TEMP=$(grep -m1 '"temp_C"' "$DATA" | sed 's/[^0-9-]*//g')
#je récupère la température actuelle en recherchant la première occurence de "temp_C"
#puis le formatage en gardant les chiffre et le "-"

TEMP_DEMAIN=$(grep '"avgtempC"' "$DATA" | sed 's/[^0-9-]*//g' | sed -n '2p')
#je récupère la temp moyenne du lendemain en récupérant toutes les lignes contenant "avgtempC"
#formatage en gardant que les chiffre encore une fois
#le dernier pipe sert à ne garder que la deuxième valeur qui correspond au lebdemain

DATE=$(date +"%Y-%m-%d -%H:%M")
#je stock la date formatée dans la variable  

echo "${DATE} -${VILLE} : ${TEMP}°C - ${TEMP_DEMAIN}°C" >> "meteo.txt"
#pour écrire dans le fichier meteo.txt sans supprimer les dernières valeurs

rm "$DATA"
#On supprime le fichier temporaire car on en a plus besoin.