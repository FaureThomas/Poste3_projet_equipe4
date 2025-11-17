#!/bin/bash

#Ce script à pour but de récupérer les donners du site internet et de les formater de sorte à voir la météo 
#d'aujourdh'ui et de demain. 

if [ $# -eq 0 ]; then
    VILLE = "Toulouse"
#On met la ville de Toulouse par defaut
	else
	VILLE = $1
#sinon il prend la première ville passé en argument
fi 


DATA="info_meteo.txt"
>"$DATA"
#Nom du fichier temporaire servant a stocker les données brute du site,  si il existe déja, on le vide ou alors on le crée.

curl -s "wttr.in/${VILLE}" -o "$DATA"
#je vais chercher en ligne les données de la ville 
#puis je les assignent à $DATA

sed -i 's/\x1B\[[0-9;]*[JKmsu]//g' "$DATA"
# Je formate le fichier info_meteo.txt pour enlever les codes ANSI (ceux qui servent aux couleurs donc innutiles) pour plus de lisibilité
# -i : modifie le fichier directement
# s/.../.../g : remplace tout ce qui correspond par rien
# \x1B\[[0-9;]*[JKmsu] : expression qui correspond à tous les codes ANSI


TEMP=$(grep -o '[+-]\?[0-9]\+' "$DATA" | head -1 | sed 's/^+//')
#Je récupère la température actuelle en cherchant toutes les occurrences de nombres
#puis je prends la première occurence.
#puis, si il y a un plus je le remplace par rien (permet de garder que le -)

DEMAIN=$(date -d tomorrow "+%a %d %b")
#je récupère la date de demain au même format que sur wttr.in pour pouvoir ensuite la rechercher avec la commande grep.

TEMP_DEMAIN=$(grep -A5 "$DEMAIN" "$DATA" | grep -o '[+-]\?[0-9]\+' | head -2 | tail -1 | sed 's/^+//')
#cherche les 5 lignes écrites après la date de demain (cela devrait contenir l'information cherchée)
#Je récupère la température de demain matin en cherchant tous les nombres
#puis je prends la deuxième occurence. (la 1ere étant la date de demain...)
#puis, si il y a un plus je le remplace par rien (permet de garder que le -)

DATE=$(date +"%Y-%m-%d -%H:%M")
#je stock la date formatée dans la variable  

if [ ! -f "meteo.txt" ]; then
    touch "meteo.txt"
fi
#Si le fichier meteo.txt n'existe pas, alors on le crée (peremet de faire marcher le script sur n'importe quelle machine an partir du simple fichier Extracteur_Météo.sh)

echo "${DATE} -${VILLE} : ${TEMP}°C - ${TEMP_DEMAIN}°C" >> "meteo.txt"
#pour écrire dans le fichier meteo.txt sans supprimer les dernières valeurs

rm "$DATA"
#On supprime le fichier temporaire car on en a plus besoin.
