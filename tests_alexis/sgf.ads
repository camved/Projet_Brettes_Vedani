with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with System;                     use System;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Ada.Containers.Doubly_Linked_Lists; 
with Ada.Containers;             use Ada.Containers;

package sgf is

   VOID_INVALID_PATH: Exception;
   VOID_ROOT_LOCATION: Exception;
   VOID_CHILD_ERROR: Exception;
   VOID_POINTER_ERROR: Exception;
   EMPTY_STRING: Exception;
   INVALID_FIRST_CHAR: Exception;
   NOT_IN_THIS_DIRECTORY: Exception;
   NOT_A_DIRECTORY: Exception;
   NOT_A_FILE: Exception;
   DIRECTORY_NOT_FOUND: Exception;
   FILE_NOT_EXIST: Exception;
   VOID_NOT_EXISTING: Exception;
   IS_PARENT: Exception;

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

   --Nom: file_or_folder (cp)
   --Objectif : copier le fichier ou rep dans un autre repertoire
   --Paramètres : path in, type String,  copied_name in, type P_file
   --Pré : copied existe dans le  et le chemin est valide
   --Post : le fichier est copié au bon endroit
   --Test : être en mesure de rverifier que le fichier copié est au bonne endroit et identique au premier
   procedure copyFile(path : in String ; copied_name : in String; current_dir : P_file );

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

   --Nom : delete (~rm)
   --Objectif : supprimer un fichier ou un répertoire
   --Paramètres : path in, type String,  current_dir in, type P_file
   --Pré : le chemin est valide et existe dans le SGF et curren_dir n'est pas vide
   --Post : l'entité voulue est bien supprimée au bon endroit
   --Test : être en mesure de vérifier que l'entité supprimée n'existe plus
   procedure delete (name_or_path: in String ; current_dir : P_file);

-------------------------------------------------------------------------------------------------

   --Nom : deleteDirectory (~rm -r)
   --Objectif : supprimer un répertoire contenant d'autres entités
   --Paramètres : path in, type String,  current_dir in, type P_file
   --Pré : le chemin est valide et existe dans le SGF et curren_dir n'est pas vide
   --Post : l'entité voulue est bien supprimée au bon endroit, et ses enfants aussi
   --Test : être en mesure de vérifier que l'entité supprimée n'existe plus et ses enfants non plus
   procedure deleteDirectory (name_or_path: in String ; current_dir : P_file);

------------------------------------------------------------------------------------------------

   --Nom : change_directory
   --Objectif : Déplacer le pwd vers le répertoire demandé
   --Paramètre : 
      -- name_file_to_go: in String
   -- Pré : 
      -- répertoire existant
      -- isRepo = True
   -- Post : current_directory = adresse du fichier cherché
   procedure changeDirectory(path : in String);

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

-------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------

   --Nom : renameOrMove (rm)
   --Objectif : change le nom ou déplace le fichier
   --Paramètres : modified_file in, type P_file, new_path in, type String
   --Pré : modified_file existe dans le sgf et le chemin est valide
   --Post : le fichier est changé de place ou renommé
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé, et quelle ait changé si changement de nom ou de repertoire suf si le chemin donné est erroné
   procedure renameOrMove(source_file : in String; new_file: in string; current_directory: in P_file);

------------------------------------------------------------------------------------------------------

   --Nom : getExisting
   --Objectif : vérifier si un fichier existe bien
   --Paramètres : 
      --fichier : in String
      --current_directory : in P_file
      --return : Boolean
   --Pré : String débutant par ".", ".." ou une lettre
   --Post : True si le fichier existe, False sinon
   function getExisting(fichier: in String; current_directory: in P_file) return Boolean;

-------------------------------------------------------------------------------------------------------

   --Nom : getExistingParent
   --Objectif: vérifier si le parent d'un fichier existe bien
   --Paramètres: 
      --fichier: in String
      --current_directory: in P_file
      --return Boolean
   --Pré:
   --Post:
   function getExistingParent(fichier: in String; current_directory: in P_file) return Boolean;

-------------------------------------------------------------------------------------------------------

   --Nom: putExisting
   --Objectif: affiche l'état d'existence du fichier
   --Paramètres : 
      --fichier : in String
      --current_directory : in P_file
      --return : Boolean
   --Pré : String débutant par ".", ".." ou une lettre
   --Post : 
   procedure putExisting(fichier: in String; current_directory: in P_file);

--------------------------------------------------------------------------------------------------------

   --Nom : getName
   --Objectif : retourner le nom du fichier sans le chemin
   --Exemple : /usr/share/alexis/file.txt renvoie file.txt
   --Paramètre :
      --path: in String
   --Pré : chemin valide
   --Post : découpage correct
   function getName(path : in String) return unbounded_string;

---------------------------------------------------------------------------------------------------------

   --Nom: interactiveMenu
   --Objectif: afficher un menu interactif qui guide l'utilisateur au maximum dans ses choix en expliquant la syntaxe et ne laissant pas de place à l'erreur
   --Paramètres: none
   --Pré: 
--   procedure interactiveMenu(current_directory: in out P_file);

----------------------------------------------------------------------------------------------------------

   function containsSlash(Text : in String) return Boolean;

----------------------------------------------------------------------------------------------------------

   --Nom: menuChoice
   --Objectif: afficher un petit menu permettant de choisir entre le menu interactif ou le CLI
   --Paramètre: none
--   procedure menuChoice(current_directory: in out P_file);

--------------------------------------------------------------------------------------------------------

   --Nom: menuTouch
   --Objectif: guider l'utilisateur dans la création d'un fichier non-directory
   --Paramètres :
      --racine: in P_file
      --current_directory: in out P_file
   --Pré :
   --Post :
--   procedure menuTouch(current_directory: in out P_file);

---------------------------------------------------------------------------------------------------------

   --Nom: menuCreate
   --Objectif: guider l'utilisateur dans la création d'un fichier, qu'il soit répertoire ou pas
   --Paramètres :
      --current_directory: in P_file
   --Pré:
   --Post:
   procedure menuCreate(current_directory: in P_file);

---------------------------------------------------------------------------------------------------------

   --Nom: menuChangeDirectory
   --Objectif: guider l'utilisateur dans le changement de son current_directory
   --Paramètres :
      --current_directory: in P_file
   --Pré:
   --Post:
   procedure menuChangeDirectory(current_directory: in P_file);

---------------------------------------------------------------------------------------------------------

   --Nom: menuRemoveFile
   --Objectif : guider l'utilisateur dans la supression d'un fichier, qu'il soit répertoire ou fichier
   --Paramètres :
      --current_directory: P_file
   --Pré:
   --Post:
   procedure menuRemoveFile(current_directory: in P_file);

---------------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------------

   --Nom: testGetPathValidity
   --Objectif: afficher à l'écran si le chemin rentré est correct ou pas
   --Paramètre: 
      --path: in String
   --Pré: String en entrée
   --Post:
   procedure testGetPathValidity(isValid: in Boolean);

---------------------------------------------------------------------------------------------------------

   --Nom: isDirectory
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

----------------------------------------------------------------------------------------------------------

   --Nom: isAncestor
   --Objectif: Renvoyer True si le répertoire est trouvé dans les parents successifs du répertoire courant
   --Paramètre:
      --current_directory: in P_file
      --return Boolean
   --Pré:
   --Post:
   function isAncestor(potential_ancestor: in P_file; current_directory: in P_file) return Boolean;

-----------------------------------------------------------------------------------------------------------

   --Nom: parseIsAncestor
   --Objectif: convertir un string en P_file pour vérifier si le fichier pointé est un ancêtre du répertoire courant
   --Paramètres:
      --path: in String
      --current_directory: in P_file
      --return P_file
   --Pré: path valide
   --Post:
   function parseIsAncestor(path: in String; current_directory: in P_file) return Boolean;

end SGF;