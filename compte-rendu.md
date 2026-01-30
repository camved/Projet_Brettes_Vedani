# Introduction

    Dans le cadre de ce projet, notre objectif a été de nous rapprocher le plus possible du fonctionnement de Linux. Nous utilisons différents systèmes d'exploitation au quotidien, tous issus de Debian (Ubuntu pour Camille, Debian, Ubuntu et Pop!_OS pour Alexis). 
    
    Ainsi, essayer de nous référer au fonctionnement nominal de ces distributions est à la fois pour nous une manière d'approfondir nos connaissances et compétences en programmation, mais également d'acquérir des connaissances plus poussées sur le fonctionnement de nos propres ordinateurs.

    Ces compétences seront transférables directement sur nos activités professionnelles, qui prendront très majoritairement place dans l'univers de Linux.

# Partie I - Interface de manipulation d'un système de gestion de fichiers

## Librairies utilisées

    Ada.Text_IO : permet l'affichage de chaînes de caractères et de lire les entrées clavier.

    Ada.Integer_Text_IO : permet l'affichage de nombres entiers.

    Ada.Strings.Unbounded : permet la création de chaînes de caractères non-bornées. Nous l'utilisons pour pouvoir permettre à l'utilisateur de rentrer des noms de fichiers de tailles variables.

    System : 

    Ada.Containers : fournit des types de base permettant de manipuler et compter des éléments dans les structures de données. Nous l'utilisons pour son type Count_Type dans displayFile.

    Ada.Characters.Handling : permet de vérifier si un caractère est une lettre, un chiffre, un alphanumérique, autre... Nous l'utilisons dans nos fonctions de parsing.

    Ada.Containers.Doubly_Linked_Lists : fournit des listes doublement chaînées, utilisées pour stocker les pointeurs donnant vers les différents enfants des répertoires.

    Ada.Strings.Fixed : offre des outils de découpe de chaînes de caractères. Nous l'utilisons pour détecter les / et ainsi découper les chemins fournis en enchaînements de nom de fichiers dans nos fonctions de parsing.

    Ada.Numerics.Discrete_Random : permet la génération de nombres aléatoires. Nous l'utilisons par exemple dans la fonction plumaSimulator pour simuler un changement de taille de fichier non-prévisible.

    Ada.Unchecked_Deallocation : permet la libération de mémoire des objets supprimés avec rm via la fonction Free.

    Ada.Exceptions : offre des variables permettant la visualisation des exceptions propres à Ada (non-créées par nous) telles que DATA_ERROR. Cela aide au débogage.


## Définition des types

### Type file

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

    Chaque fichier possède un seul répertoire parent. Les fichiers simples possèdent une liste d'enfant vide contrairement aux répertoires.

### P_file

    TYPE P_file EST POINTEUR SUR TYPE file 

    Ce type permet d'accéder aux différents champs de notre type abstrait de données. Les différents champs de ce type sont ce qui caractérise le fichier. 

### P_list

    TYPE P_list EST POINTEUR SUR File_List_Pkg.List

    *Ce type est introduit par la librairie Ada.Containers.Doubly_Linked_Lists*

    Cette librairie permet de rajouter des champs à cette liste facilement. Nous l'utilisons pour gérer la liste des enfants des différents répertoires.

## Gestion des droits

### L'approche Linux

    Linux définit chaque utilisateur avec 10 caractères.
    Exemple sur le répertoire musique de la machine Pop!_OS : drwxr-xr-x
    
    d : directory, il s'agit d'un répertoire. Un fichier serait décrit avec -

    rwx : les droits du user considéré comme le "owner" du fichier. Ici, read, write, execute.

    r-x : les droits des utilisateurs situés dans le groupe du "owner". Ici, read and execute.

    r-x : les droits des autres utilisateurs. Idem.

### Notre approche

    Nous avons fait le choix de ne pas le reproduire. Au démarrage de notre programme, nous nous "connectons" en rentrant une chaîne de caractère. 

    Un fichier créé prend automatiquement comme "owner" l'utilisateur actuellement "connecté". On peut changer librement d'utilisateur.

    Un fichier ne peut être supprimé ou déplacé que par son propriétaire. S'il est copié par un autre utilisateur, l'original ne changera pas de "owner". La copie aura l'utilisateur qui aura effectué la copie comme "owner".

## Création d'un SGF ne contenant que le fichier racine

### initRacine

#### Spécifications

    Nom : initRacine
    Objectif : Créer un répertoire racine / vide et accessible par n'importe qui
    Paramètres :
        - root : in out file
    Pré : pas de répertoire racine créé
    Post : un répertoire racine créé
    Test : se trouver dedans
    procedure initRacine (root: in out file);

#### Raffinage

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

#### Code

    Tous les codes sont disponibles dans le fichier sgf.adb. Nous ne les copions pas ici car cela n'a pas grand intérêt.

## Obtention du répertoire courant (commande pwd)

### getCurrentPath

#### Spécifications

    Nom : getCurrentPath (pwd)
    Objectif : Retourner le chemin absolu du fichier actuel
    Paramètres : 
        - pwd_file: in P_file
        - return: Unbounded_String
    Pré : current_file existe dans le sgf
    Post : le chemin absolu du fichier actuel est retourné
    Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
    function getCurrentPath(pwd_file : in P_file) return Unbounded_String;

#### Raffinage

    R0 : Retourner le chemin absolu du fichier actuel

    R1 : Comment "Retourner le chemin absolu du fichier actuel" ?

    SI pwd_file = null ALORS
        LEVER VOID_POINTER_ERROR AVEC "Error: file is null"
    FIN SI
    SI pwd_file.Rep_Parent = null ALORS
        APPELER RECURSIVEMENT getCurrentPath
    FIN SI

    R2 : Comment "Appeler récursivement getCurrentPath" ?

     parent_path <- getCurrentPath(pwd_file.Rep_Parent);
     RETOURNER (parent_path & "/" & pwd_file.nom)

## Création d'un fichier / création d'un répertoire (commandes touch et mkdir)

### createFile

#### Remarques

    Comme nous sommes partis sur le principe du "tout est fichier" propre à Linux, nous avons ici une fonction qui, grâce au changement d'un paramètre d'entrée, permet de créer un fichier simple ou un répertoire.

    mkdir : créé un répertoire (champ .isRepo = True)

    touch : créé un fichier simple (champ .isRepo = False)

### Spécifications

    Nom : createFile
    Objectif : Créer un fichier dont on choisit le nom à l'endroit de notre choix
    Paramètres :
        - nom_or_path : in String
        - isRepo : in Boolean
        - memoire : in out Mem
    Pré : 
        - pas de fichier nommé pareil dans le répertoire père souhaité
        - répertoire parent est bien un répertoire (file.rep_parent.all.isRepo = True)
    Post :
        - fichier fils bien créé et conforme à ce qui est demandé
    procedure createFile(nom_or_path : in String ; isRepo : in Boolean ; memoire : in out Mem);

#### Raffinage

    R0 : créer un fichier dont on choisit le nom dans le répertoire de notre choix

    R1 : Comment "créer un fichier dont on choisit le nom dans le répertoire de notre choix" ?

    Extraire le répertoire parent
    
    SI nom_or_path CONTIENT UN SLASH ALORS
        RECUPERER LA PARTIE APRES LE DERNIER SLASH
    SINON
        nom <- To_Unbounded_String(nom_or_path)
    FIN SI

    pointer_created <- RESERVE LA MEMOIRE POUR UN TYPE file
    pointer_created.nom <- nom
    pointer_created.droits_acces <- sgf.current_user
    pointer_created.taille <- 10
    pointer_created.rep_parent <- Target_Parent
    pointer_created.isRepo <- isRepo
    pointer_created.adress <- allocateMem(memoire, pointer_created.taille)

    SI isRepo ALORS
        pointer_created.L_enfant <- nouvelle File_List_Pkg.List
    SINON
        pointer_created.L_enfant <-  null
    FIN SI

    GERER LE PARENT

    R2 : Comment "Récupérer la partie après le dernier slash" ?

    Last_Slash <-  Ada.Strings.Fixed.Index(nom_or_path, "/", Going => Ada.Strings.Backward)
    nom <- nom := To_Unbounded_String(nom_or_path(Last_Slash + 1 .. nom_or_path'Last))

    R2 : Comment "Gérer le parent" ? 

    SI pointer_created.rep_parent = null ALORS
        Ecrire("Erreur : Impossible de trouver le dossier parent.")
    SINON SI
        Ecrire("Erreur : La destination '" & To_String(pointer_created.rep_parent.nom) & "' n'est pas un répertoire.")
    SINON 
        pointer_created.rep_parent.L_enfant.Append(pointer_created)
    FIN SI

#### Remarque

    Avec du recul en faisant le compte-rendu, nous nous sommes rendus comptes que réserver la mémoire avant de gérer le parent n'est pas la façon la plus optimisée. Il existe des cas où l'on réserve de la mémoire pour qu'au final le parent n'existe pas. 

    Note de Alexis (ex Réseaux et Télécommunications) : ce projet est particulièrement intéressant pour ce type de cas. C'est la première fois que je dois m'occuper de réaliser un travail de programmation sur plusieurs semaines. C'est suffisant pour progresser et prendre du recul sur ce que l'on a fait au début du projet.

## Changement de répertoire courant en précisant le chemin du nouveau répertoire courant (commande cd)

### changeDirectory

##### Spécifications

    Nom : changeDirectory
    Objectif : changer la valeur de current_file vers un répertoire choisi
    Paramètres :
        path : in String
        current_directory : in out P_file
    Pré : le chemin est valide et mène à un répertoire existant
    Post : sgf.current_directory bien modifié
    Test : vérifier que le current_directory corresponde bien au répertoire concerné par le chemin
    procedure changeDirectory(path : in  String; current_directory: in out P_file)

#### Raffinage

    R0 : changer la valeur de current_file vers un répertoire choisi

    R1 : Comment "changer la valeur de current_file vers un répertoire choisi" ?

    Utiliser parsePath pour trouver le répertoire cible

    SI destination /= null ET ALORS destination.isRepo ALORS
        current_directory <-  destination
    SINON
        Lever NOT_A_DIRECTORY
    FIN SI
    
    R2 : Comment "Utiliser parsePath pour trouver le répertoire cible" ?

    destination <- parsePath(path, current_directory)

## Affichage du contenu, fichiers et répertoires, du répertoire désigné par un chemin (commande ls placeholder). Si le chemin n'est pas précisé, le contenu du répertoire courant est affiché (commande ls)

### displayFileContent

#### Spécifications

    Nom : displayFileContent
    Objectif : afficher tout le contenu du répertoire actuel
    Paramètres :
        path_or_name_to_display : in String
    Pré : 
        path_or_name_to_display existe dans le système de gestion de fichiers
    Post :
        Tout le contenu s'affiche
    Test :
        Vérification humaine que tout s'affiche à l'écran après l'appel de la procédure
    procedure displayFileContent(path_or_name_to_display : in String)

#### Raffinage

    R0 : afficher tout le contenu du répertoire actuel

    R1 : Comment "afficher tout le contenu du répertoire actuel" ?

    Chercher l'objet visé par le chemin
    Gérer le cas où le chemin n'existe pas
    Gérer le cas où c'est un fichier
    Récupérer la liste des enfants
    Gérer l'affichage

    R2 : Comment "chercher l'objet visé par le chemin" ?

    to_display <- parsePath(path_or_name_to_display, SGF.current_directory)

    R2 : Comment "gérer le cas où le chemin n'existe pas" ?

    SI to_display = null ALORS
        Ecrire("Error : Path not found")
        Retourner
    FIN SI

    R2 : Comment "gérer le cas où c'est un fichier" ?

    SI NON to_display.isRepo ALORS
        Ecrire("Content: " & To_String(to_display.nom))
        Retourner
    FIN SI

    R2 : Comment "récupérer la liste des enfants" ?

    list_ptr <- getChildren(to_display)

    R2 : Comment "gérer l'affichage" ?

    SI list_ptr /= null ET ALORS NON list_ptr.all.Is_Empty ALORS
        POUR CHAQUE child DE list_ptr.all FAIRE
            Ecrire(To_String(child.nom))
        FIN POUR
    SINON
        Ecrire("(Empty directory)")
    FIN SI

## Affichage des fichiers et des répertoires du répertoire courant et de tous les fichiers et répertoires de tous les sous-répertoires (commande ls -r)

### displayFileContentRecursive

#### Spécifications

    Nom : displayFileContentRecursive
    Objectif : permettre l'affichage du contenu d'un répertoire de manière récursive (ls -r)
    Paramètres :
        -path_or_name_to_display : in String
        -current_dir : P_file
    Pré : 
        - path_or_name_to_display pointe sur un fichier existant
    Post :
    procedure displayFileContentRecursive(path_or_name_to_display : in String; current_dir : P_file; indent : Natural := 0)

#### Raffinage

    R0 : permettre l'affichage du contenu d'un répertoire de manière récursive

    R1 : Comment "permettre l'affichage du contenu d'un répertoire de manière récursive" ?

    SI path_or_name_to_display = "." OU path_or_name_to_display = "" ALORS
        to_display <- current_dir
    SINON SI containsSlash (path_or_name_to_display) ALORS
        Chercher le fichier/répertoire demandé
    FIN SI

    Gérer le cas où il est introuvable

    Gérer l'affichage et la récursion

    R2 : Comment "chercher le fichier/répertoire demandé" ?

        current_parent <- extractParent(path_or_name_to_display, current_dir)
        children_list_ancestor <- getChildren(current_parent)
        to_display <- findChild(children_list_ancestor.all, To_String(getName(path_or_name_to_display)))
    SINON
        current_parent <- current_dir
        children_list_ancestor <- getChildren(current_dir)
        to_display <- findChild(children_list_ancestor.all, path_or_name_to_display)

    R2 : Comment "gérer le cas où il est introuvable" ?

    SI to_display = null ALORS
        Retourner
    FIN SI

    R2 : Comment "gérer l'affichage et la récursion" ?

    Gérer le cas où c'est un fichier
    Gérer le cas où c'est un répertoire vide
    Gérer les autres cas

    R3 : Comment "gérer le cas où c'est un fichier" ?

    SI NON to_display.isRepo ALORS
        Ecrire(indent_str & "|-- [F] " & To_String(to_display.nom))
    
    R3 : Comment "gérer le cas où c'est un répertoire vide" ?

    SINON SI to_display.isRepo ET ALORS to_display.L_enfant.all.Is_Empty ALORS
        Ecrire(indent_str & "|-- [D] " & To_String(to_display.nom) & " (Vide)")
    
    R3 : Comment "gérer les autres cas" ?

    SINON
        SI path_or_name_to_display /= "." ALORS
            Ecrire(indent_str & "|-- [D] " & To_String(to_display.nom))
        SINON SI
        POUR CHAQUE Child_File DE getChildren(to_display).all FAIRE
            displayFileContentRecursive(
               To_String(Child_File.nom), to_display, indent + 4)
        FIN POUR
    FIN SI

## Suppression d'un fichier (commande rm)

### delete

#### 