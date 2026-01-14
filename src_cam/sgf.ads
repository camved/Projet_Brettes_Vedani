with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with System;
with Ada.Containers;             use Ada.Containers;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Strings.Fixed;          use Ada.Strings.Fixed;


package SGF is 

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
      ID: System.Address;
      L_enfant : P_list;
      isRepo: Boolean;
   
   end record;

   
   VOID_POINTER_ERROR : exception;
   VOID_CHILD_ERROR : exception;
   NOT_IN_THIS_DIRECTORY : exception;
   NOT_A_DIRECTORY : exception;

   --Nom : initRacine
   --Objectif : Créer un répertoire racine / vide et accessible par n'importe qui
   --Paramètres : root in out, type file
   --Pré : pas de répertoire racine créé
   --Post : un répertoire racine créé
   --Test : être en mesure de se déplacer dans le répertoire racine avec cd une fois le répertoire racine créé
    procedure initRacine (root: in out file);

   --Nom : createFile
   --Objectif : Créer un fichier dont on choisit le nom, les droits à l'endroit de notre choix.
   --Paramètres :
   --Pré : pas de fichier appelé pareil créé dans le répertoire père
   --Post :
   -- répertoire parent est bien un répertoire (file.rep_parent.all.isRepo = True)
   -- fichier fils bien créé et conforme à ce qui est demandé
   procedure createFile (nom_or_path: in String; isRepo : in Boolean);

   --Nom : getCurrentPath(pwd)
   --Objectif : Retourner le chemin absolu du fichier actuelle
   --Paramètres : current_file in, type P_file
   --Pré : current_file existe dans le sgf
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   function getCurrentPath(pwd_file : in P_file) return Unbounded_String;

   --Nom : getChildren
   --Objectif : Retourner le pointeur des enfants 
   --Paramètres : adress_file in, type P_file
   --Pré : le fichier pointé par adress_file existe, le pointeur de la liste d'enfant existe  
   --Post : le pointeur de l liste d'enfant est retourné
   --Test : être en mesure de retourner l'adresse de la liste enfant.
   function getChildren(adress_file : in P_file) return P_list;

   --Nom : findChild
   --Objectif : chercher dans la liste des enfants 
   --Paramètres : children_list in, type List, child_to_find in, type String
   --Pré : La liste n'est pas vide, 
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   function findChild(children_list : in List; child_to_find : in String) return P_file;

   --Nom : get_current_directory
   --Objectif : Retourner le chemin absolu du fichier actuelle
   --Paramètres : current_file in, type P_file
   --Pré : current_file existe dans le sgf
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   function getCurrentDirectory return P_file;

   
   --Nom : changeDirectory(cd)
   --Objectif : changer la valeur de current_file
   --Paramètres : name_file_to_go
   --Pré : le chemin est valide et mène à un répertoire existant
   --Post : le current directory du module SGF est bien changé
   --Test : vérifier que le current directory corrrespond bien au fichier concerné par le chemin
   procedure changeDirectory(path : in String) ;

      
   --Nom : displayFile (print)
   --Objectif : Affiche la structure de donnée "fichier" (File) en donnant un pointeur (P_file)
   --Paramètres : file_to_show in, type P_file
   --Pré : file_to_show existe dans le sgf
   --Post : le fichier donné est affiché sur la console
   --Test : être en visualiser un fichier créer.
   procedure displayFile(file_to_show : in P_file);

   --Nom: parseRelative
   --Objectif: renvoyer l'adresse du fichier cherché
   --Paramètres:
      --fichier: in String
      --current_directory: in P_file
   --Pré: chemin relatif uniquement -> premier caractère = lettre ou .
   --Post: adresse renvoyée
   --Exception: NOT_EXISTING
   function parseRelative (fichier: in String; Current_Directory: in P_file) return P_file;

   --Nom: parseAbsolute
   --Objectif: renvoyer l'adresse du fichier cherché
   --Paramètres: 
      --fichier: in String
      --current_directory: in P_file
   --Pré: chemin absolu uniquement
   --Post: adresse renvoyée
   --Exception: NOT_EXISTING
   function parseAbsolute (fichier: in String; current_directory: in P_file) return P_file;

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

   --  --Nom : changeSize
   --  --Objectif : Change la taille du fichier 
   --  --Paramètres : size in, type Integer, modified_file in , type File
   --  --Pré : current_filemodified_file existe dans le sgf et ne dépasse le 1 Terra
   --  --Post : la taille du fichier est changée
   --  --Test : la taille du fichier est bien modifiée et égale à la taille+10 ko
   --  procedure changeSize(size : in Integer; modified_file : in File);

   --Nom : display_file_content (ls)
   --Objectif : afficher tous le contenus du repertoire actuel
   --Paramètres : current_file in, type P_file
   --Pré : current_file existe dans le sgf
   --Post : tout le contenu s'affiche
   --Test : tout s'affiche à l'écran après l'appel de la fonction
   procedure displayFileContent(current_directory : in P_file) ;

   --Nom: findRoot
   --Objectif: renvoyer l'adresse de la racine
   --Paramètre: 
   --Pré: racine créée
   --Post: l'adresse de la racine est renvoyée
   function findRoot (current_directory:  in P_file) return P_file;

   --Nom : getName
   --Objectif : extraire le nom d'un fichier manipulé lorsque son chemin est donné
   --Paramètres : path in, type String
   --Pré : le cgemin est valide et existe dans le sgf
   --Post : le nom du fichier (dernière partie du chemin) est retournée
   --Test : tout s'affiche à l'écran après l'appel de la fonction
   function getName(path : String) return unbounded_string;

   --Nom : containsSlash
   --Objectif : déterminer si un string contient le symbole "/"
   --Paramètres : Text in, type String
   --Pré : 
   --Post : renvoie true si oui, false si non.
   --Test : constater que la valeur retournée d'un texte correcpond à la valeur 
   -- attendue pour un contenant des slashs et l'autre non.
   function containsSlash(Text : in String) return Boolean;

      --Nom: extractParent
   --Objectif : Renvoyer l'adresse du parent du fichier visé
   --Exemple : entrée "/file1/file2/file.txt" renvoie l'adresse de /file1/file2
   --Paramètres : 
      -- fichier : in String
      -- current_directory : in P_file
   --Pré :
      --String de taille > 0
      --Premier caractère lettre ou . ou /
   --Post : 
      --Adresse valide renvoyée en hexadécimale
      --Erreur renvoyée si n'existe pas
   --Exceptions : 
      --=> EMPTY_STRING
      --=> INVALID_FIRST_CHAR
      --=> FILE_NOT_EXIST
   function extractParent (fichier: in String; current_directory: in P_file) return P_file;

   --  --Nom : display_file_all (ls -r)
   --  --Objectif : afficher tous le contenus du repertoire actuel et des répertoire qu'il contient 
   --  --Paramètres : current_file in, type P_file, path in , type string
   --  --Pré : current_file existe dans le sgf
   --  --Post : tout le contenu du fichier s'affiche et ses contenants aussi
   --  --Test : tout s'affiche à l'écran après l'appel de la fonction
   --  function display_file_all(path : in String ; folder : in File) return Unbounded_String; --recursif de l'autre

   --  --Nom : rename_or_move (rm)
   --  --Objectif : change le nom ou déplace le fichier
   --  --Paramètres : modified_file in, type P_file, new_path in, type String
   --  --Pré : modified_file existe dans le sgf et le chemin est valide
   --  --Post : le fichier est changé de place ou renommé
   --  --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé, et quelle ait changé si changement de nom ou de repertoire suf si le chemin donné est erroné
   --  procedure rename_or_move( modified_file : in File; new_path : in string);

   --Nom : copy_file_or_folder (cp)
   --Objectif : copier le fichier ou rep dans un autre repertoire
   --Paramètres : path in, type String,  copied_name in, type P_file
   --Pré : copied existe dans le  et le chemin est valide
   --Post : le fichier est copié au bon endroit
   --Test : être en mesure de vérifier que le fichier copié est au bonne endroit et identique au premier
   procedure copy_file(path : in String ; copied_name : in String; current_dir : P_file );
   
   --Nom : delete (~rm)
   --Objectif : supprimer un fichier ou un répertoire
   --Paramètres : path in, type String,  current_dir in, type P_file
   --Pré : le chemin est valide et existe dans le SGF et curren_dir n'est pas vide
   --Post : l'entité voulue est bien supprimée au bon endroit
   --Test : être en mesure de vérifier que l'entité supprimée n'existe plus
   procedure deleteFile (name_or_path: in String ; current_dir : P_file);

   --Nom : deleteDirectory (~rm -r)
   --Objectif : supprimer un répertoire contenant d'autres entités
   --Paramètres : path in, type String,  current_dir in, type P_file
   --Pré : le chemin est valide et existe dans le SGF et curren_dir n'est pas vide
   --Post : l'entité voulue est bien supprimée au bon endroit, et ses enfants aussi
   --Test : être en mesure de vérifier que l'entité supprimée n'existe plus et ses enfants non plus
   procedure deleteDirectory (name_or_path: in String ; current_dir : P_file);

   
   --  --Nom : assert_same_file (==)
   --  --Objectif : ccomparer deux fichier et vérifier qu'il soit identique ou non
   --  --Paramètres : copied in, type P_file, path in String
   --  --Pré : copied existe dans le  SGF et le chemin est valide 
   --  --Post : le fichier  1 est comparé au fichier 2
   --  --Test : être en mesure de rverifier que le fichier 1 est égale à lui-même et pas à un autre
   --  procedure assert_same_file (file1 : in File; file2 : in File);


end SGF;