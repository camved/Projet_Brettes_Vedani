# Spécificités

    Sur Linux, tout est fichier => pas de différence entre fichier et répertoire
    Quelque chose qui se calcule ne se stocke pas :
        => Chemin absolu résolu en récursif

# A faire

    [] Penser à la privacy/limitation des types


# Déclaration des types

    file : enregistrement avec 
    - nom : string
    - droit accès : string de 3 caractères (r w x -)
    - taille : entier
    - rep parent : pointeur vers type file
    - autres (selon sujet)
    - liste enfant : pointeurs vers
    - is_repository : boolean

    pwd : enregistrement avec
    - pointeur vers file parent
    - string

plus qu'un main après, il vaudrait mieux partir sur un module SGF, avec un pointeur où l'utilisateur se trouve actuellement.

# Sous-programmes à faire

    I. getCheminAbsolu : fonction
    getName : fonction 
    getParent : fonction

    II. getSpace : fonction qui affiche l'espace disponible restant



