with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with System;                     use System;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Ada.Containers.Doubly_Linked_Lists; 
with Ada.Containers;             use Ada.Containers;

package sgf is 

   type file; --Déclaration partielle pour permettre le pointeur suivant

   type P_file is access file;

   package File_List_Pkg is new Ada.Containers.Doubly_Linked_Lists(P_file);
   use File_List_Pkg;
   type P_list is access File_List_Pkg.List;

   type file is record

      nom: unbounded_string;
      droits_acces: String (1..9);
      taille: Integer;
      rep_parent: P_file;
      L_enfant: P_list;
      isRepo: Boolean;
   
   end record;

   root: file;
   current_directory: P_file;

----------------------------------------------------------------------------------------------

   --Nom : initRacine
   --Objectif : Créer un répertoire racine / vide et accessible par n'importe qui
   --Paramètres : root in out, type file
   --Pré : pas de répertoire racine créé
   --Post : un répertoire racine créé
   --Test : être en mesure de se déplacer dans le répertoire racine avec cd une fois le répertoire racine créé
   procedure initRacine (root: in out file);

----------------------------------------------------------------------------------------------

   --Nom : createFile
   --Objectif : Créer un fichier dont on choisit le nom, les droits à l'endroit de notre choix.
   --Paramètres :
   --Pré : pas de fichier appelé pareil créé dans le répertoire père
   --Post :
      -- répertoire parent est bien un répertoire (file.rep_parent.all.isRepo = True)
      -- fichier fils bien créé et conforme à ce qui est demandé
   procedure createFile (nom: in String; isRepo: in Boolean);

-------------------------------------------------------------------------------------------

   --Nom : removeFile
   --Objectif : Supprimer un fichier existant et supprime récursivement tout son contenu selon l'appel fait
   --Paramètre : 
      -- fichier : in string
   --Pré : fichier existant
   --Post : 
      -- répertoire père du fichier ne contient plus le fichier
      -- SI APPEL AVEC -r LES FICHIERS ET REPERTOIRES CONTENUS SONT SUPPRIMES
   --Test : afficher le contenu du répertoire père
   --procedure removeFile (fichier: in String);

------------------------------------------------------------------------------------------------

   --Nom : change_directory
   --Objectif : Déplacer le pwd vers le répertoire demandé
   --Paramètre : 
      -- name_file_to_go: in String
   -- Pré : 
      -- répertoire existant
      -- isRepo = True
   -- Post : current_directory = adresse du fichier cherché
   procedure changeDirectory(name_file_to_go : in String);

------------------------------------------------------------------------------------------------

   --Nom: parseRelative
   --Objectif: renvoyer l'adresse du fichier cherché
   --Paramètres:
      --fichier: in String
      --current_directory: in P_file
   --Pré: chemin relatif uniquement -> premier caractère = lettre ou .
   --Post: adresse renvoyée
   --Exception: NOT_EXISTING
   function parseRelative (fichier: in String; Current_Directory: in P_file) return P_file;

------------------------------------------------------------------------------------------------

   --Nom: parseAbsolute
   --Objectif: renvoyer l'adresse du fichier cherché
   --Paramètres: 
      --fichier: in String
      --current_directory: in P_file
   --Pré: chemin absolu uniquement
   --Post: adresse renvoyée
   --Exception: NOT_EXISTING
   function parseAbsolute (fichier: in String; current_directory: in P_file) return P_file;

------------------------------------------------------------------------------------------------

   --Nom : parsePath
   --Objectif : Renvoyer l'adresse du répertoire ou du fichier visé
   --Paramètre :
      -- fichier : in String
      -- ID : out Address
   --Pré : 
      --String de taille > 0
      --Premier caractère lettre ou . ou /
   --Post :
      --Adresse valide renvoyée en hexadécimale
      --Erreur renvoyée si n'existe pas
   --Exceptions : 
      --=> EMPTY_STRING
      --=> INVALID_FIRST_CHAR
   function parsePath (fichier: in String; current_directory: in P_file) return P_file;

-------------------------------------------------------------------------------------------------

   --Nom: findRoot
   --Objectif: renvoyer l'adresse de la racine
   --Paramètre: 
   --Pré: racine créée
   --Post: l'adresse de la racine est renvoyée
   function findRoot (current_directory:  in P_file) return P_file;

--------------------------------------------------------------------------------------------------

   --Nom: findChild
   --Objectif: renvoyer l'adresse du fils cherché dans la liste s'il existe et une erreur s'il n'existe pas
   --Paramètre:
   --Pré: 
   --Post: 
   --Exception: 
   function findChild (children_list: in List; child_to_find: in String) return P_file;

---------------------------------------------------------------------------------------------------

   --Nom : getCurrentPath (pwd)
   --Objectif : Retourner le chemin absolu du fichier actuelle
   --Paramètres : current_file in, type P_file
   --Pré : current_file existe dans le sgf
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   function getCurrentPath(pwd_file : in P_file) return Unbounded_String;

--------------------------------------------------------------------------------------------------

   --Nom : getChildren
   --Objectif : Retourner le pointeur des enfants 
   --Paramètres : adress_file in, type P_file
   --Pré : le fichier pointé par adress_file existe, le pointeur de la liste d'enfant existe  
   --Post : le pointeur de la liste d'enfant est retourné
   --Test : être en mesure de retourner l'adresse de la liste enfant.
   function getChildren(adress_file : in P_file) return P_list;

-------------------------------------------------------------------------------------------------------

   --Nom: displayFile
   --Objectif: afficher les attributs du fichier courant
   --Paramètres:
      --current_directory: in P_file
   --Pré : le fichier existe
   --Post : bien affiché
   procedure displayFile(current_directory : in P_file);

-------------------------------------------------------------------------------------------------------

   --Nom : displayFileContent (ls)
   --Objectif : afficher tous le contenus du repertoire actuel
   --Paramètres :
      --file_to_show: in P_file
   --Pré : current_file existe dans le sgf
   --Post : tout le contenu s'affiche
   --Test : tout s'affiche à l'écran après l'appel de la fonction
   procedure displayFileContent(current_directory: in P_file);


end SGF;