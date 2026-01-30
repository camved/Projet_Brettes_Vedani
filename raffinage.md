# Introduction

    Dans le cadre de ce projet, notre objectif a été de nous rapprocher le plus possible du fonctionnement de Linux. Nous utilisons différents systèmes d'exploitation au quotidien, tous issus de Debian (Ubuntu pour Camille, Debian, Ubuntu et Pop!_OS pour Alexis). 
    
    Ainsi, essayer de nous référer au fonctionnement nominal de ces distributions est à la fois pour nous une manière d'approfondir nos connaissances et compétences en programmation, mais également d'acquérir des connaissances plus poussées sur le fonctionnement de nos propres ordinateurs.

    Ces compétences seront transférables directement sur nos activités professionnelles, qui prendront très majoritairement place dans l'univers de Linux.



# Définition des types

## file

    TYPE file EST ENREGISTREMENT
        nom: chaîne de caractère de taille non-définie
        droits_acces: chaîne de 9 caractères
        taille: entier
        rep_parent: P_file
        L_enfant: P_list
        isRepo: booléen
    FIN ENREGISTREMENT

    Ce type abstrait de donnée est notre représentation du fichier. Nous essayons de coller au maximum à la philosophie Linux qui dit que tout est fichier. Ainsi, les répertoires sont des fichiers ayant simplement un booléen à True.

    Ce type n'est utilisé que pour initialiser la racine et les fichiers. C'est les seules fois où l'on manipule un type file directement. 

    Chaque fichier possède un seul répertoire parent. Fichiers simples comme répertoires possèdent une liste d'enfant, mais des contrôles dans les procédures de création et de déplacement de fichiers empêchent de se retrouver avec des fichiers contenus dans des fichiers simples.

## P_file

    TYPE P_file EST POINTEUR SUR TYPE file 

    Ce type permet d'accéder aux différents champs de notre type abstrait de données. Les différents champs de ce type sont ce qui caractérise le fichier. 

## P_list

    TYPE P_list EST POINTEUR SUR File_List_Pkg.List

    *Ce type est introduit par la librairie Ada.Containers.Doubly_Linked_Lists*

    Cette librairie permet de rajouter des champs à cette liste facilement.  

# Définition des exceptions

    VOID_INVALID_PATH : cette exception est levée dès lors que l'on essaie d'accéder à un fichier via un chemin erroné. De multiples sous-programmes sont en mesure de la déclencher : il peut s'agir d'un chemin impossible car ne respectant pas les syntaxes de noms que l'on a fixées, d'un chemin respectant la syntaxe mais pointant sur un fichier qui n'existe pas.


    VOID_ROOT_LOCATION : cette exception est levée lorsque l'on essaie de supprimer la racine. 
    Nous sommes conscients que Linux permet de le faire, cela n'a pas d'intérêt. Il faudrait obligatoirement redémarrer le programme ensuite.
    Sur Linux, comme tout est fichier, même les périphériques et les disques montés, il n'y aurait pas le moindre avantage à le permettre.

    VOID_POINTER_ERROR : cette exception détecte lorsqu'un fichier n'existe pas.

    NOT_A_DIRECTORY : cette exception est levée lorsqu'on essaie d'utiliser des fonctions propres aux répertoires (isRepo = True) sur des fichiers simples. Cela permet de bien séparer les usages entre les commandes liées aux répertoires (cd, rm -r, ls -r...) et les commandes liées aux fichiers ordinaires.

    FILE_NOT_EXIST : cette exception est levée lorsqu'un répertoire est vide. Il s'agit d'un cas plus précis de VOID_INVALID_PATH.

    VOID_NOT_OWNER : cette exception est levée lorsqu'un utilisateur essaie de réaliser certaines actions sur un fichier ne lui appartenant pas, cf. la rubrique sur notre approche au début.
    

# Définition des sous-programmes

## initRacine

### Spécifications

    Nom : initRacine
    Objectif : Créer un répertoire racine / vide et accessible par n'importe qui
    Paramètres :
        - root : in out file
    Pré : pas de répertoire racine créé
    Post : un répertoire racine créé
    Test : se trouver dedans
    procedure initRacine (root: in out file);
    
### Raffinage

    R0 : créer un répertoire racine

    R1 : Comment "créer un répertoire racine" ? 

        Déclarer une variable de type file
        Affecter des valeurs à ses différents champs
        L'affecter à la racine

    R2 : Comment "déclarer une variable de type file" ?

        pointer_root : pointeur vers file
        pointer_root <- alouer un nouvel objet de type file

    R2 : Comment "affecter des valeurs à ses différents champs" ?

        pointer_root.nom <- ""
        pointer_root.droits_acces <- "rwxrwxrwx"
        pointer_root.taille <- 1
        pointer_root.rep_parent <- null --Par définition, le répertoire racine n'a pas de parent
        pointer_root.L_enfant <- type File_List_Pkg.List
        pointer_root.isRepo <- True

    R2 : Comment "l'affecter à la racine" ?

        root <- pointer_root
        current_directory <- pointer_root

### Remarques

    1To/10Ko = 100 000 000 (si on compte en puissances de 10 et pas de 2)
    On considère donc que chaque fichier pèse 1 par défaut et peut être augmenté en multiples de 1 (et donc de 10Ko) jusqu'à la limite de 100 000 000.

## createFile

### Spécifications

    Nom : createFile
    Objectif : créer un fichier dont on choisit le nom, les droits et l'emplacement de notre choix
    Paramètres :
        - nom_or_path : in String
        - isRepo : in Boolean
    Pré : pas de fichier appelé pareil créé dans le répertoire père (???)
    Post : fichier créé existant dans la liste d'enfant du répertoire parent
    procedure createFile(nom_or_path: in String; isRepo: in Boolean);

### Déclaration des variables locales

    pointer_created : P_file
    nom : unbounded_string
    Target_Parent : P_file
    Last_Slash : Natural

### Raffinage

    (A FAIRE)

### Remarques

    Le type Natural est un sous-type de Integer qui va de 0 à la limite supérieure. Il peut être utilisé lorsque la valeur n'est jamais amenée à être négative.

## getName

### Spécifications

    Nom : getName
    Objectif : retourner le nom du fichier sans le chemin
    Exemple : /usr/share/alexis_camille/raptor.txt renvoie raptor.txt
    Paramètres : 
        - path : in String
    Pré : chemin valide
    Post : découpage correct
    function getName(path : in String) return unbounded_string;

### Déclaration des variables locales    

    last_Slash_Index : Natural

### Raffinage

    R0 : extraire le nom du fichier du chemin

    R1 : comment "extraire le nom du fichier du chemin" ?

        SI containsSlash(path) ALORS
            Extraire le nom 
        SINON
            RETOURNER path
        FIN SI

    R2 : comment "extraire le nom" ?

        last_Slash_Index <- Ada.Strings.Fixed.Index(Source => path, Pattern => "/", Going => Ada.Strings.Backward)
        RETOURNER To_Unbounded_String(path(last_Slash_Index + 1 .. path'Last))

### Remarques

    To_Unbounded_String est une fonction issue de la librairie Ada.Strings.Unbounded qui permet d'utiliser des chaînes de caractères non-bornées. Il est important de les convertir en chaînes bornées ou non-bornées car ce sont bien des types différents.


## containsSlash

### Spécifications

    Nom : containsSlash
    Objectif : déterminer si un string contient le symbole '/'
    Paramètres :
        - Text : in String
    Pré :
    Post : renvoie True si oui, False si non
    function containsSlash(Text: in String) return Boolean;

### Raffinage

    R0 : déterminer si un string contient le symbole '/' 

    R1 : comment "déterminer si un string contient le symbole '/'" ?

        Parcourir le string jusqu'à trouver un '/'

    R2 : comment "parcourir le string jusqu'à trouver un '/'" ?

        RETOURNER (Ada.Strings.Fixed.Index(Text, "/" > 0))

### Remarques

    Cette fonction est disponible grâce à la librarie Ada.Strings.Fixed. 

## findRoot

### Spécifications

    Nom : findRoot
    Objectif : renvoyer l'adresse de la racine
    Paramètres :
        - current_directory : in P_file
    Pré : racine créée
    Post : 
    function findRoot(current_directory: in P_file) return P_file;

### Raffinage

    R0 : renvoyer l'adresse de la racine

    R1 : comment "renvoyer l'adresse de la racine" ? 

        SI current_directory = null ALORS 
        --cas où la racine n'est pas créée OU nous ne sommes pas dans le système de gestion de fichiers
            RETOURNE null
        SINON SI current_directory.all.rep_parent = null ALORS 
        --cas où nous sommes à la racine car seule la racine n'a pas de parent
            RETOURNE current_directory
        SINON
        --cas où nous sommes dans le système de gestion de fichiers et pas à la racine
            RETOURNE findRoot(current_directory.all.rep_parent)
        FIN SI

##