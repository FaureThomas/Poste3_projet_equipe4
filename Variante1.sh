#!/bin/bash

if [ $# -eq 0 ]; then
    VILLE="Toulouse"
else
    VILLE=$1
fi

DATE_METEOTXT=$(date +"%Y%m%d")
DIR_SCRIPT="$(dirname "$0")"
METEO="${DIR_SCRIPT}/meteo${DATE_METEOTXT}.txt"

DATA="info_meteo.txt"
curl -s --max-time 10 "wttr.in/${VILLE}?format=%t|%w|%h|%v&no-terminal" -o "$DATA"

if [ ! -s "$DATA" ]; then
    echo "Erreur : impossible de récupérer les données météo pour $VILLE."
    exit 1
fi

RAW=$(cat "$DATA")
# Supprimer séquences ANSI éventuelles
RAW=$(echo "$RAW" | sed 's/\x1B\[[0-9;]*[JKmsu]//g')

IFS='|' read -r TEMP VENT HUMIDITE VISIBILITE <<< "$RAW"

# Nettoyer TEMP (enlever +)
TEMP="${TEMP#+}"

# Nettoyer VENT (ne garder que les chiffres et km/h)
VENT_CHIFFRES=$(echo "$VENT" | grep -o '[0-9]\+ *km/h')
if [ -z "$VENT_CHIFFRES" ]; then
    VENT_CHIFFRES="N/A"
fi

# Visibilité
if [ -z "$VISIBILITE" ]; then
    VISIBILITE="N/A"
fi

DATE=$(date +"%Y-%m-%d -%H:%M")

# Exemple d'écriture
echo "${DATE} -${VILLE} : ${TEMP}°C - Vent : ${VENT_CHIFFRES} - Humidite : ${HUMIDITE} - Visibilite : ${VISIBILITE}" >> "$METEO"

rm "$DATA"
