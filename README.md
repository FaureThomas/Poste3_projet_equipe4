Extracteur_Météo.sh
Version 1:

Objectif : Ecrire la météo du jour et les prévisions pour le lendemain d'une ville dans un fichier meteo.txt selon ce format :
YYYY-MM-DD -HH:MM -Ville : [Température actuelle]°C - [Prévisions]°C

Comment éxécuter le script :
Dans un terminal, aller dans le répértoire contenant le script (via la commande cd), puis taper :
./Extracteur_Météo.sh <ville>
(Le script doit prendre en compte un paramètre <ville>)

Sortie du script :
Cas 1: oubli de renseigner la ville,
    Le script renvoie "Usage: ./Extracteur_Météo.sh <ville>" dans le terminal.
Cas 2: Le fichier meteo.txt n'existe pas :
    Le script crée un fichier meteo.txt et écrit "YYYY-MM-DD -HH:MM -Ville : [Température actuelle]°C - [Prévisions]°C" dedans.
Cas 3: Le fichier meteo.txt existe mais est vide :
    Le script écrit dans meteo.txt : "YYYY-MM-DD -HH:MM -Ville : [Température actuelle]°C - [Prévisions]°C"
Cas 4: Le fichier meteo.txt existe, mais il n'est pas vide :
    Le script écrit une nouvelle ligne "YYYY-MM-DD -HH:MM -Ville : [Température actuelle]°C - [Prévisions]°C" à la suite des autres lignes.


Résumé du script :
1: S'assure qu'il y à un paramètre, sinon renvoie : "Usage: ./Extracteur_Météo.sh <ville>"
2: Crée un fichier temporaire info_meteo.txt si il n'existe pas, ou le vide sinon.
3: Récupère les données brutes du site wttr.in et les écrit dans le fichier info_meteo.txt
4: Création d'une variable stockant la température actuelle via la commande grep (part chercher l'info dans info_meteo.txt)
5: Création d'une variable stockant les prévisions pour demain via la commande grep (part chercher l'info dans info_meteo.txt)
6: Création d'une variable DATE pour stocker la date du jour.
7: Si il n'existe pas déjà, création d'un fichier meteo.txt
8: Via la commande echo, et en mettant toutes les variables dans le bon ordre, on peut écrire la ligne "YYYY-MM-DD -HH:MM -Ville : [Température actuelle]°C - [Prévisions]°C" dans meteo.txt
9: Supprime le fichier temporaire info_meteo.txt car nous n'en avons plus besoin.
