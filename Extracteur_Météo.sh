#!/bin/bash

#Ce script à pour but de récupérer les donners du site internet et de les formater de sorte à voir la météo 
#d'aujourdh'ui et de demain. 

if [ $# -eq 0 ]; then
    VILLE="Toulouse"
#On met la ville de Toulouse par defaut
	else
	VILLE=$1
#sinon il prend la première ville passé en argument
fi

#Vérification de l'argument (la ville)
FORMAT_JSON = false
if [ "$2" == "--json" ]; then
        FORMAT_JSON = true
fi

DATE_METEOTXT=$(date +"%Y%m%d")
#On crée une variable pour stocker la date du jour au format demandé dans la version 3 (YYYYMMDD)

DIR_SCRIPT="$(dirname "$0")"
METEO="${DIR_SCRIPT}/meteo"$DATE_METEOTXT".txt"

# Si le script est lancé via cron, $0 contient le chemin complet + le nom du script.
#J'utilise dirname pour enlève le nom du fichier et garde uniquement le chemin du script.
#Adaptation du nom du fichier meteo.txt en utilisant la variable DATE_METEOTXT pour se diriger vers le fichier correspondant au bon jour
# DIR_SCRIPT contient ainsi le chemin réel, évitant que meteoYYYYMMDD.txt soit créé dans le répertoire de base, comme cron a tendance à le faire.
#Modification du chemin emplyoyé pour se diriger vers meteoYYYYMMDD.txt au lieu de meteo.txt

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

if [ ! -f "$METEO" ]; then
    touch "$METEO"
fi
#Si le fichier meteoYYYYMMDD.txt n'existe pas, alors on le crée (peremet de faire marcher le script sur n'importe quelle machine an partir du simple fichier Extracteur_Météo.sh)

echo "${DATE} -${VILLE} : ${TEMP}°C - ${TEMP_DEMAIN}°C" >> "$METEO"
#pour écrire dans le fichier meteoYYYYMMDD.txt sans supprimer les dernières valeurs

rm "$DATA"
#On supprime le fichier temporaire car on en a plus besoin.

# Exemple de ligne à ajouter dans crontab -e pour exécuter le script toutes les 4 minutes
# */4 * * * * /chemin/vers/le/dossier/Extracteur_Météo.sh alors
# Ici, $0 contiendra /chemin/vers/le/dossier/Extracteur_Météo.sh et dirname($0) permettra de récupérer /chemin/vers/le/dossier, correspondant à DIR_SCRIPT

if [ "$FORMAT_JSON" = true ]; then
	NOUVELLE_ENTREE="{
		\"date\": \"$DATE\",
		\"heure\": \"$HEURE\",
		\"ville\": \"$VILLE\",
		\"temperature_actuelle\": \"${TEMP_ACTUELLE}°C\",
		\"temperature__prevision\": \"${TEMP_PREVISION}°C\",
		\"vitesse_vent\": \"${VITESSE_VENT} km/h\",
		\"humidite\": \"${TAUX_HUMIDITE}%\",
		\"visibilite\": \"${VISIBILITE} km\"
	}"
	rm "meteo_$VILLE.txt"
	if [ -f "meteo.json" ]; then
		sed -i '$ s/],$/],/' meteo.json
		echo ",$NOUVELLE_ENTREE]" >> meteo.json
	else
		echo "[$NOUVELLE_ENTREE]" > meteo.json
	fi
fi
