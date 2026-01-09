with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with System;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Ada.Containers.Doubly_Linked_Lists;

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
   VOID_CHILD_EROOR : exception;

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
   procedure createFile (nom: in String; isRepo : in Boolean);

   --Nom : getCurrentFile (pwd)
   --Objectif : Retourner le chemin absolu du fichier actuelle
   --Paramètres : current_file in, type P_file
   --Pré : current_file existe dans le sgf
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   function getCurrentPath(pwd_file : in P_file) return Unbounded_String;

   function getChildren(adress_file : in P_file) return P_list;

   function findChild(children_list : in List; child_to_find : in String) return P_file;

   function get_current_directory return P_file;


   --  --Nom : changeSize
   --  --Objectif : Change la taille du fichier 
   --  --Paramètres : size in, type Integer, modified_file in , type File
   --  --Pré : current_filemodified_file existe dans le sgf et ne dépasse le 1 Terra
   --  --Post : la taille du fichier est changée
   --  --Test : la taille du fichier est bien modifiée et égale à la taille+10 ko
   --  procedure changeSize(size : in Integer; modified_file : in File);

   --  --Nom : display_file_content (ls)
   --  --Objectif : afficher tous le contenus du repertoire actuel
   --  --Paramètres : current_file in, type P_file, path in , type string
   --  --Pré : current_file existe dans le sgf
   --  --Post : tout le contenu s'affiche
   --  --Test : tout s'affiche à l'écran après l'appel de la fonction
   --  function display_file_content(path : in String ; folder : in File) return Unbounded_String;

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

   --  --Nom : copy_file_or_folder (cp)
   --  --Objectif : copier le fichier ou rep dans un autre repertoire
   --  --Paramètres : copied in, type P_file, path in String
   --  --Pré : copied existe dans le  et le chemin est valide
   --  --Post : le fichier est copié au bon endroit
   --  --Test : être en mesure de rverifier que le fichier copié est au bonne endroit et identique au premier
   --  procedure copy_file_or_folder (copied : in File; path : in String);

   --  --Nom : assert_same_file (==)
   --  --Objectif : ccomparer deux fichier et vérifier qu'il soit identique ou non
   --  --Paramètres : copied in, type P_file, path in String
   --  --Pré : copied existe dans le  SGF et le chemin est valide 
   --  --Post : le fichier  1 est comparé au fichier 2
   --  --Test : être en mesure de rverifier que le fichier 1 est égale à lui-même et pas à un autre
   --  procedure assert_same_file (file1 : in File; file2 : in File);


end SGF;