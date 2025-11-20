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

# Vérification de l'option JSON
FORMAT_JSON=false
if [ "$2" == "--json" ]; then
	FORMAT_JSON=true
	#Si l'utilisateur demande le format JSON, on active la sortie JSON
fi

DATE_METEOTXT=$(date +"%Y%m%d")
#On crée une variable pour stocker la date du jour au format demandé dans la version 3 (YYYYMMDD)

DIR_SCRIPT="$(dirname "$0")"
METEO="${DIR_SCRIPT}/meteo_${DATE_METEOTXT}.txt"

# Si le script est lancé via cron, $0 contient le chemin complet + le nom du script.
#J'utilise dirname pour enlève le nom du fichier et garde uniquement le chemin du script.
#Adaptation du nom du fichier meteo.txt en utilisant la variable DATE_METEOTXT pour se diriger vers le fichier correspondant au bon jour
# DIR_SCRIPT contient ainsi le chemin réel, évitant que meteoYYYYMMDD.txt soit créé dans le répertoire de base, comme cron a tendance à le faire.
#Modification du chemin emplyoyé pour se diriger vers meteoYYYYMMDD.txt au lieu de meteo.txt

DATA="info_meteo.txt"
#>"$DATA"
#Nom du fichier temporaire servant a stocker les données brute du site,  si il existe déja, on le vide ou alors on le crée.

#Le curl permet de prendre le format necessaire afin d'afficher vent, humidité et visibilité.
#curl pour la variante 1:
curl -s --max-time 10 "wttr.in/${VILLE}" -o "$DATA"
#je vais chercher en ligne les données de la ville 
#puis je les assignent à $DATA

sed -i 's/\x1B\[[0-9;]*[JKmsu]//g' "$DATA"
# Je formate le fichier info_meteo.txt pour enlever les codes ANSI (ceux qui servent aux couleurs donc innutiles) pour plus de lisibilité
# -i : modifie le fichier directement
# s/.../.../g : remplace tout ce qui correspond par rien
# \x1B\[[0-9;]*[JKmsu] : expression qui correspond à tous les codes ANSI

#Variante 1:

if [ ! -s "$DATA" ]; then
    echo "Erreur : impossible de récupérer les données météo pour $VILLE."
    exit 1
fi

#TEMP utiliser pour les versions:
TEMP=$(grep -m1 -o '[+-]\?[0-9]\+°C' "$DATA" | sed 's/^+//')

DEMAIN=$(date -d tomorrow "+%a %d %b")
#je récupère la date de demain au même format que sur wttr.in pour pouvoir ensuite la rechercher a$

TEMP_DEMAIN=$(grep -A5 "$DEMAIN" "$DATA" | grep -o '[+-]\?[0-9]\+' | head -2 | tail -1 | sed 's/^+$
#cherche les 5 lignes écrites après la date de demain (cela devrait contenir l'information cherché$
#Je récupère la température de demain matin en cherchant tous les nombres   
#puis je prends la deuxième occurence. (la 1ere étant la date de demain...) 
#puis, si il y a un plus je le remplace par rien (permet de garder que le -)

if [ -z "$TEMP_DEMAIN" ]; then
    TEMP_DEMAIN="N/A"
    #Si wttr.in ne renvoie pas la prévision, je l'indique proprement.
fi

#On récupère ces valeurs avec un second curl en format simplifié pour garantir une extraction stable
EXTRA_DATA=$(curl -s --max-time 10 "wttr.in/${VILLE}?format=%t|%w|%h|%v&no-terminal")

IFS='|' read -r _ VENT HUMIDITE VISIBILITE <<< "$EXTRA_DATA"
#Je découpe les valeurs dans l'ordre t|w|h|v
#La température n'est pas utilisée ici car nous avons déjà TEMP depuis le texte complet.

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
#je stock la date formatée dans la variable 
HEURE=$(date +"%H:%M")
#pareil pour l'heure

if [ ! -f "$METEO" ]; then
    touch "$METEO"
fi
#Si le fichier meteoYYYYMMDD.txt n'existe pas, alors on le crée (peremet de faire marcher le script sur n'importe quelle machine an partir du simple fichier Extracteur_Météo.sh)

if [ "$FORMAT_JSON" = true ]; then

    # Construction de l'objet JSON 
    NOUVELLE_ENTREE="{
    \"date\": \"$DATE\",
    \"heure\": \"$HEURE\",
    \"ville\": \"$VILLE\",
    \"temperature\": \"$TEMP\",
    \"prevision\": \"$TEMP_DEMAIN\",
    \"vent\": \"$VENT_CHIFFRES\",
    \"humidite\": \"$HUMIDITE\",
    \"visibilite\": \"$VISIBILITE\"
}"
    echo "$NOUVELLE_ENTREE" > "meteo_${VILLE}.json"
    #On écrase le fichier JSON pour ne garder qu'une seule entrée (exigence du sujet).

else
    echo "${DATE} -${HEURE} -${VILLE} : ${TEMP} - ${TEMP_DEMAIN} - Vent : ${VENT_CHIFFRES} - Humidite : ${HUMIDITE} - Visibilite : ${VISIBILITE}" >> "$METEO"
    #Ligne conforme à toutes les variantes.

fi

rm "$DATA"
#On supprime le fichier temporaire car on en a plus besoin.

# Exemple de ligne à ajouter dans crontab -e pour exécuter le script toutes les 4 minutes
# */4 * * * * /chemin/vers/le/dossier/Extracteur_Météo.sh alors
# Ici, $0 contiendra /chemin/vers/le/dossier/Extracteur_Météo.sh et dirname($0) permettra de récupérer /chemin/vers/le/dossier, correspondant à DIR_SCRIPT

