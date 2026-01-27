with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with System;
with Ada.Containers;             use Ada.Containers;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Strings.Fixed;          use Ada.Strings.Fixed;
with Ada.Numerics.Discrete_Random;
with Ada.Unchecked_Deallocation;

package sgf is

--SGF types

   type file; --Déclaration partielle pour permettre le pointeur suivant

   type P_file is access file;

   package File_List_Pkg is new Ada.Containers.Doubly_Linked_Lists(P_file);
   use File_List_Pkg;
   type P_list is access File_List_Pkg.List;

   type file is record

      nom: unbounded_string;
      droits_acces: unbounded_string;
      taille: Integer;
      rep_parent: P_file;
      L_enfant: P_list;
      isRepo: Boolean;

   end record;

--SGF elements

   root: file;
   current_directory: P_file;
   current_user: unbounded_string;

--SGF exception

   VOID_INVALID_PATH: Exception;
   VOID_ROOT_LOCATION: Exception;
   VOID_CHILD_ERROR: Exception;
   VOID_POINTER_ERROR: Exception;
   EMPTY_STRING: Exception;
   INVALID_FIRST_CHAR: Exception;
   NOT_IN_THIS_DIRECTORY: Exception;
   NOT_A_DIRECTORY: Exception;
   FILE_NOT_EXIST: Exception;
   VOID_NOT_EXISTING: Exception;
   VOID_NOT_OWNER: Exception;

-- specs

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

   --Nom : delete (~rm)
   --Objectif : supprimer un fichier ou un répertoire
   --Paramètres : path in, type String,  current_dir in, type P_file
   --Pré : le chemin est valide et existe dans le SGF et curren_dir n'est pas vide
   --Post : l'entité voulue est bien supprimée au bon endroit
   --Test : être en mesure de vérifier que l'entité supprimée n'existe plus
   procedure delete (name_or_path: in String ; current_dir : P_file);

   --Nom : deleteDirectory (~rm -r)
   --Objectif : supprimer un répertoire contenant d'autres entités
   --Paramètres : path in, type String,  current_dir in, type P_file
   --Pré : le chemin est valide et existe dans le SGF et curren_dir n'est pas vide
   --Post : l'entité voulue est bien supprimée au bon endroit, et ses enfants aussi
   --Test : être en mesure de vérifier que l'entité supprimée n'existe plus et ses enfants non plus
   procedure deleteDirectory (name_or_path: in String ; current_dir : P_file);

   --Nom : getChildren
   --Objectif : Retourner le pointeur des enfants 
   --Paramètres : adress_file in, type P_file
   --Pré : le fichier pointé par adress_file existe, le pointeur de la liste d'enfant existe  
   --Post : le pointeur de la liste d'enfant est retourné
   --Test : être en mesure de retourner l'adresse de la liste enfant.
   function getChildren(adress_file : in P_file) return P_list;

   --Nom : findChild
   --Objectif : chercher dans la liste des enfants 
   --Paramètres : children_list in, type List, child_to_find in, type String
   --Pré : La liste n'est pas vide, 
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   function findChild(children_list : in List; child_to_find : in String) return P_file;

   --Nom: displayFile
   --Objectif: afficher les attributs du fichier courant
   --Paramètres:
      --current_directory: in P_file
   --Pré : le fichier existe
   --Post : bien affiché
   procedure displayFile(current_directory : in P_file);

   --Nom : containsSlash
   --Objectif : déterminer si un string contient le symbole "/"
   --Paramètres : Text in, type String
   --Pré : 
   --Post : renvoie true si oui, false si non.
   --Test : constater que la valeur retournée d'un texte correcpond à la valeur 
   -- attendue pour un contenant des slashs et l'autre non.
   function containsSlash(Text : in String) return Boolean;

   --Nom : getName
   --Objectif : retourner le nom du fichier sans le chemin
   --Exemple : /usr/share/alexis_camille/raptor.txt renvoie raptor.txt
   --Paramètre :
      --path: in String
   --Pré : chemin valide
   --Post : découpage correct
   function getName(path : in String) return unbounded_string;

   --Nom: parseAbsolute
   --Objectif: renvoyer l'adresse du fichier cherché
   --Paramètres: 
      --fichier: in String
      --current_directory: in P_file
   --Pré: chemin absolu uniquement
   --Post: adresse renvoyée
   --Exception: NOT_EXISTING
   function parseAbsolute (fichier: in String; current_directory: in P_file) return P_file;

   --Nom: parseRelative
   --Objectif: renvoyer l'adresse du fichier cherché
   --Paramètres:
      --fichier: in String
      --current_directory: in P_file
   --Pré: chemin relatif uniquement -> premier caractère = lettre ou .
   --Post: adresse renvoyée
   --Exception: NOT_EXISTING
   function parseRelative (fichier: in String; Current_Directory: in P_file) return P_file;

   --Nom: displayOwner
   --Objectif: afficher le owner d'un fichier cherché
   --Paramètres: 
      --path: in String
      --current_directory: in P_file
   --Pré: 
   --Post:
   procedure displayOwner(path: in String; current_directory: in P_file);

   --Nom: menuDisplayOwner
   --Objectif: permettre à l'utilisateur de saisir le fichier dont il veut voir l'owner
   --Paramètres:
      --current_directory: in P_file
   --Pré:
   --Post:
   procedure menuDisplayOwner(current_directory: in P_file);

   --Nom : parsePath
   --Objectif : Renvoyer l'adresse du répertoire ou du fichier visé
   --Paramètre :
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
   function parsePath (fichier: in String; current_directory: in P_file) return P_file;

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

   --Nom : getExisting
   --Objectif : vérifier si un fichier existe bien
   --Paramètres : 
      --fichier : in String
      --current_directory : in P_file
      --return : Boolean
   --Pré : String débutant par ".", ".." ou une lettre
   --Post : True si le fichier existe, False sinon
   function getExisting(fichier: in String; current_directory: in P_file) return Boolean;

   --Nom : getExistingParent
   --Objectif: vérifier si le parent d'un fichier existe bien
   --Paramètres: 
      --fichier: in String
      --current_directory: in P_file
      --return Boolean
   --Pré:
   --Post:
   function getExistingParent(fichier: in String; current_directory: in P_file) return Boolean;

   --Nom: putExisting
   --Objectif: affiche l'état d'existence du fichier
   --Paramètres : 
      --fichier : in String
      --current_directory : in P_file
      --return : Boolean
   --Pré : String débutant par ".", ".." ou une lettre
   --Post : 
   procedure putExisting(fichier: in String; current_directory: in P_file);

   --Nom: testGetPathValidity
   --Objectif: afficher à l'écran si le chemin rentré est correct ou pas
   --Paramètre: 
      --path: in String
   --Pré: String en entrée
   --Post:
   procedure testGetPathValidity(isValid: in Boolean);

   --Nom: getPathValidity
   --Objectif : vérifier si le path est valide. On autorise :
      -- les lettres, chiffres, '.', '_', '-' et '/'
   --Paramètres :
      -- path: in String
      -- return: Boolean
   --Pré : String en entrée
   --Post : 
   --Tests: via testGetPathValidity
   function getPathValidity (path: in String) return Boolean;

   --Nom : isDirectory
   --Objectif: renvoyer si un fichier donné en entrée est un répertoire ou pas
   --Paramètre: 
      --path: in String
      --current_directory: in P_file
      --return Boolean 
   --Pré: 
      --le fichier donné en entrée existe
      --le fichier donné en entrée a un format correct
   --Post:
   function isDirectory(path: in String; current_directory: in P_file) return Boolean;

   --Nom: findRoot
   --Objectif: renvoyer l'adresse de la racine
   --Paramètre: 
      --current_directory: in P_file
   --Pré: racine créée
   --Post: l'adresse de la racine est renvoyée
   function findRoot (current_directory:  in P_file) return P_file;

   --Nom : getCurrentDirectory
   --Objectif : Retourner le chemin absolu du fichier actuelle
   --Paramètres : current_file in, type P_file
   --Pré : current_file existe dans le sgf
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   function getCurrentDirectory return P_file;

   function plumaSimulator return Integer;

   --Nom : changeDirectory(cd)
   --Objectif : changer la valeur de current_file
   --Paramètres :
      --path: in String
      --current_directory: in out P_file
   --Pré : le chemin est valide et mène à un répertoire existant
   --Post : le current directory du module SGF est bien changé
   --Test : vérifier que le current directory corrrespond bien au fichier concerné par le chemin
   procedure changeDirectory(path : in  String; current_directory: in out P_file) ;

   --Nom : getCurrentPath (pwd)
   --Objectif : Retourner le chemin absolu du fichier actuelle
   --Paramètres : current_file in, type P_file
   --Pré : current_file existe dans le sgf
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   function getCurrentPath(pwd_file : in P_file) return Unbounded_String;

   --Nom : displayFileContent (ls)
   --Objectif : afficher tous le contenus du repertoire actuel
   --Paramètres :
      --path_or_name_to_display: in String
   --Pré : le fichier correspondant a path_or_name_to_display existe dans le sgf
   --Post : tout le contenu s'affiche
   --Test : tout s'affiche à l'écran après l'appel de la fonction
   procedure displayFileContent(path_or_name_to_display : in String);

   procedure displayFileContentRecursive(path_or_name_to_display : in String; current_dir : P_file; indent : Natural := 0);

   --Nom : copy
   --Objectif : procedure outils qui va copier un fichier ou repertoire dans un autre fichier
   --Paramètres : to_be_copied in, type P_file,  new_parent in, type P_file
   --Pré : to_be_copied existe bien
   --Post : le fichier est copié au bon endroit
   --Test : être en mesure de vérifier que le fichier copié est au bonne endroit et identique au premier
   procedure copy(to_be_copied : in P_file; new_parent : in P_file);

   --Nom : copyFile (cp)
   --Objectif : copier le fichier ou le rep dans un autre repertoire de facon recurssive si le rep a des enfants
   --Paramètres : path in, type String,  copied_name_or_path in, type String, current_dir : P_file 
   --Pré : copied existe dans le repertoire designe et le chemin est valide pour acceder au parent
   --Post : le fichier est copié au bon endroit
   --Test : être en mesure de vérifier que le fichier copié est au bonne endroit et identique au premier
   procedure copyRepoFile(copied_name_or_path : in String; path : in String; current_dir : P_file );

   --Nom : menuSwitchUser
   --Objectif : changer d'utilisateur
   --Paramètres :
   --Pré : 
   --Post :
   procedure menuSwitchUser;

   --Nom: changeSize
   --Objectif : 
   --Paramètres :
      --file: in P_file
      --
   --procedure changeSize(file : in P_file; new_data : in Integer);

   --Nom: menuCreate
   --Objectif: guider l'utilisateur dans la création d'un fichier, qu'il soit répertoire ou pas
   --Paramètres :
      --current_directory: in P_file
   --Pré:
   --Post:
   procedure menuCreate(current_directory: in P_file);

   --Nom: menuChangeDirectory
   --Objectif: guider l'utilisateur dans le changement de son current_directory
   --Paramètres :
      --current_directory: in out P_file
   --Pré:
   --Post:
   procedure menuChangeDirectory(current_directory: in out P_file);

   --Nom: menuRemoveFile
   --Objectif : guider l'utilisateur dans la supression d'un fichier, qu'il soit répertoire ou fichier
   --Paramètres :
      --current_directory: P_file
   --Pré:
   --Post:
   procedure menuRemoveFile(current_directory: in P_file);

   -- Dans sgf.ads
   function Match_Pattern(FileName : String; Pattern : String) return Boolean;
   function getRegexFiles (pattern : String; current_dir : P_file) return P_list;
   --Nom: menuRenameOrMove
   --Objectif : guider l'utilisateur dans le déplacement d'un fichier
   --Paramètres :
      --source_file: in String
      --new_file: in String
      --current_directory: in P_file
   --Pré: racine créée
   --Post: 
   procedure menuRenameOrMove(current_directory: in P_file);

   --procedure : switchUser
   --Objectif : permettre le changement d'utilisateur
   --Paramètres : 
   --Pré :
   --Post : 
      --sgf.current_user = string rentré
   procedure switchUser;

   --procedure displayUser
   --Objectif : afficher l'utilisateur actuellement connecté
   --Paramètres :
   --Pré :
   --Post :
   procedure displayUser;

   --Nom : isOwner
   --Objectif : dire si le current_user est le propriétaire ou pas
   --Paramètres : 
      --file: in P_file
   --Pré : sgf.current_user /= null
   --Post : False if sgf.current_user /= file.droits_acces, True sinon
   function isOwner (file: in P_file) return Boolean;

   --Nom: interactiveMenu
   --Objectif: guider l'utilisateur à travers l'exécution de toutes les commandes
   --Paramètres: 
      --current_directory: in out P_file
   --Pré: racine créée
   --Post: 
   procedure interactiveMenu(current_directory: in out P_file);

   --Nom: menuDisplayFile
   --Objectif: permettre l'affichage du contenu d'un répertoire (= ls) ou récursivement de tous les répertoires (ls -r)
   --Paramètres:
      --current_directory: in P_file
   --Pré: isExisting(racine)
   --Post: 
   procedure menuDisplayFile(current_directory: in P_file);


end sgf;