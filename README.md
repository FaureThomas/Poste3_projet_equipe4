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
5: creation d'une variable DEMAIN pour stocker la date de demain (afin de pouvoir chercher la date de demain, voir étape 6)
5: Création d'une variable stockant les prévisions pour demain via la commande grep (part chercher l'info dans info_meteo.txt en cherchant les lignes à partir de DEMAIN)
7: Création d'une variable DATE pour stocker la date du jour.
8: Si il n'existe pas déjà, création d'un fichier meteo.txt
9: Via la commande echo, et en mettant toutes les variables dans le bon ordre, on peut écrire la ligne "YYYY-MM-DD -HH:MM -Ville : [Température actuelle]°C - [Prévisions]°C" dans meteo.txt
10: Supprime le fichier temporaire info_meteo.txt car nous n'en avons plus besoin.

Version 2:

La première consigne correspond à l’utilisation d’une ville par défaut afin que le script fonctionne dans tous les cas. Pour ce faire, il faut ajouter une condition qui définit une ville par défaut, ici Toulouse et qui conservera cette valeur tant qu’aucune autre ville n’est fournie en paramètre.

## CRON

Pour faire fonctionner **cron**, il faut commencer par exécuter la commande 
``
crontab -e
``
afin d’éditer la table des tâches planifiées.\
Cron sert à automatiser le lancement de scripts à intervalles réguliers (par exemple : chaque heure).
Une ligne cron est composée de 5 champs (parfois 6 ou 7 selon la configuration) qui représentent chacun une valeur de planification.

Cron utilise 5 astérisques, chacun correspondant à une unité de temps, suivis du chemin vers le fichier à exécuter. Par exemple :

```bash
0 8 * * * chemin : le script se lancera tous les jours à 8h00
*/4 * * * * chemin : le script s’exécutera toutes les 4 minutes
```
Pour obtenir le bon chemin, on peut utiliser la commande ``pwd``, récupérer le chemin affiché, puis l’intégrer dans la ligne cron.
(Attention : il faut d’abord se placer dans le dossier où se trouve le script avant d’utiliser pwd.)

Il faut noter que **cron ne fonctionne pas partout** : il est disponible uniquement sur les systèmes **Linux/Unix.**
Il existe donc des alternatives pour les autres systèmes :

**Windows** : Task Scheduler (Planificateur de tâches)\
**macOS** : launchd (launchctl)

### Étapes pour configurer correctement cron ###
**1. Se rendre dans le dossier où se trouve le script.**\
 Il est important d’être dans le bon dossier avant toute manipulation.

**2. Si vous ne vous souvenez plus du chemin exact, utilisez :**
``pwd``
cette commande affiche le chemin complet du dossier actuel. Par exemple, cela peut afficher :``/home/user/scripts``\
Gardez ce chemin, car vous l’utiliserez ensuite dans la ligne cron.

**3. Ouvrir la configuration cron avec :**
```bash 
crontab -e
```
Cette commande ouvre le fichier où l’on ajoute les lignes de planification.

**4. Ajouter la ligne cron, par exemple :**

```bash
*/4 * * * * /chemin/vers/le/dossier/Extracteur_Météo.sh 
#cet script s’exécutera toutes les 4 minutes
```
Cette ligne doit être ajoutée dans le fichier ouvert par ``crontab -e``.\
Enregistrer le fichier, ce qui active automatiquement la tâche cron.

### Gestion des chemins dans le script

Quand **cron** lance un script, il le fait souvent depuis le répertoire home, pas celui du script.
Pour éviter que ``meteo.txt`` soit créé au mauvais endroit, on a modifié le script ``Extracteur_Météo.sh`` avec :
```bash

DIR_SCRIPT="$(dirname "$0")"
METEO="${DIR_SCRIPT}/meteo.txt"

```

``$0`` contient **le chemin complet + nom du script**, par ex. ``/home/user/scripts/Extracteur_Météo.sh``.
Il est fourni automatiquement par le shell ou cron au moment de l’exécution et correspond à la façon dont le script est appelé.

Depuis le terminal : ``./Extracteur_Météo.sh``  ``$0`` = ``./Extracteur_Météo.sh``\
Depuis cron : ``/home/user/scripts/Extracteur_Météo.sh``  ``$0`` = ``/home/user/scripts/Extracteur_Météo.sh``.

``dirname "$0"`` garde uniquement le dossier : ``/home/user/scripts``, qui est stocké dans la variable ``DIR_SCRIPT``.

Ainsi, les fichiers sont toujours créés dans le dossier du script, que ce soit depuis cron ou depuis le terminal.

Version 3 :

Le script de la version 3 se comporte comme la version 2 (qui est lui même une amélioration de la version 1). Donc les objectif de la version 3 sont les mêmes.
La seule différence de cette version par rapport aux autres est la gestion d'historique :

Désormais, au lieu d'écrire la ligne "YYYY-MM-DD -HH:MM -Ville : [Température actuelle]°C - [Prévisions]°C" dans meteo.txt (ou de créer ce fichier avant d'y écrire la ligne si il n'existe pas), la température actuelle ainsi que les prévisions pour demain matin sont écrites dans un fichier météoYYYYMMDD.txt.

Pour ce faire, on a stocké la date du jour (au format YYYYMMDD) dans une variable (DATE_METEOTXT), puis au lieu de déclarer que le fichier de sortie est "meteo.txt", on déclare que le fichier de sortie est : "meteo"$DATE_METEOTXT".txt"

Par exemple, dans la version 2 on a :

DIR_SCRIPT="$(dirname "$0")"
METEO="${DIR_SCRIPT}/meteo.txt"
(ce script va créer meteo.txt si il n'existe pas (grace à la boucle "if" située en fin de script), puis écrire la météo sur une nouvelle ligne à chaque fois que le script sera lancé, y compris si il est automatisé avec cron).

Dans la version 3 on a :

DATE_METEOTXT=$(date +"%Y%m%d")
DIR_SCRIPT="$(dirname "$0")"
METEO="${DIR_SCRIPT}/meteo"$DATE_METEOTXT".txt"
(idem que dans la version 2, sauf que la météo sera écrite dans un fichier nommé meteoYYYYMMDD.txt)

Voici donc les cas possibles :

Le script est lancé pour la première fois aujourd'hui ou que meteoYYYYMMDD.txt n'existe pas : création du fichier (exemple pour aujourd'hui : meteo20251118.txt), et écrit la ligne "YYYY-MM-DD -HH:MM -Ville : [Température actuelle]°C - [Prévisions]°C" dedans.

Le script a déja été lancé aujourd'hui ou meteoYYYYMMDD.txt existe déjà : écrit la ligne "YYYY-MM-DD -HH:MM -Ville : [Température actuelle]°C - [Prévisions]°C" à la suite du fichier meteoYYYYMMDD.txt .
