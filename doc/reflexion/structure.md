# Spécificités

    Sur Linux, tout est fichier => pas de différence entre fichier et répertoire
    Quelque chose qui se calcule ne se stocke pas :
        => Chemin absolu résolu en récursif
    10Ko standard de base donc 1To / 10Ko = 1 073 741 824 / 10 => La taille globale est de (arrondi) : 107 374 182, 4

# A faire

    [] Penser à la privacy/limitation des types

# Déclaration des types

    file : enregistrement avec 
    - nom : unbounded string
    - droit accès : string de 9 caractères (r w x -)
    - taille : entier
    - rep parent : pointeur vers type file
    - autres (selon sujet)
    - liste enfant : pointeurs vers
    - is_repository : boolean

# Sous-programmes à faire

    I. 
        getCheminAbsolu : fonction
        getName : fonction 
        getParent : fonction
        initRacine : procédure
        getPwd : fonction
        exists : fonction

    II. 
        getSpace : fonction qui affiche l'espace disponible restant



 /nom1/nom2/nom3
    pwd : enregistrement avec
    - pointeur vers file parent
    - string
