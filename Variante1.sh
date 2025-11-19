#!/bin/bash
#Pour la variante 1, on reprend le script des version, ici sans les commentaire pour une meilleure visibilitée
if [ $# -eq 0 ]; then
    VILLE="Toulouse"
else
    VILLE=$1
fi

DATE_METEOTXT=$(date +"%Y%m%d")
DIR_SCRIPT="$(dirname "$0")"
METEO="${DIR_SCRIPT}/meteo${DATE_METEOTXT}.txt"

DATA="info_meteo.txt"

#Le curl permet de prendre le format necessaire afin d'afficher vent, humidité et visibilité.
curl -s --max-time 10 "wttr.in/${VILLE}?format=%t|%w|%h|%v&no-terminal" -o "$DATA"

if [ ! -s "$DATA" ]; then
    echo "Erreur : impossible de récupérer les données météo pour $VILLE."
    exit 1
fi

RAW=$(cat "$DATA")
# Supprimer séquences ANSI éventuelles
RAW=$(echo "$RAW" | sed 's/\x1B\[[0-9;]*[JKmsu]//g')

IFS='|' read -r TEMP VENT HUMIDITE VISIBILITE <<< "$RAW"


TEMP="${TEMP#+}"

# Nettoyer VENT (ne garder que les chiffres et km/h) afin d'éviter les problèmes d affichage
VENT_CHIFFRES=$(echo "$VENT" | grep -o '[0-9]\+ *km/h')
if [ -z "$VENT_CHIFFRES" ]; then
    VENT_CHIFFRES="N/A"
fi

# Visibilité
if [ -z "$VISIBILITE" ]; then
    VISIBILITE="N/A"
fi

DATE=$(date +"%Y-%m-%d -%H:%M")

echo "${DATE} -${VILLE} : ${TEMP}°C - Vent : ${VENT_CHIFFRES} - Humidite : ${HUMIDITE} - Visibilite : ${VISIBILITE}" >> "$METEO"

rm "$DATA"
