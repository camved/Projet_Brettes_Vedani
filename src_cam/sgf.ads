with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;

package SGF is 

   type file; --Déclaration partielle pour permettre le pointeur suivant

   type P_file is access file;

   type file is record

      nom: unbounded_string;
      droits_acces: String (1..9);
      taille: Integer;
      rep_parent: P_file;
      L_enfant: P_file;
      isRepo: Boolean;
   
   end record;

   
   VOID_POINTER_ERROR : exception;

   --Nom : initRacine
   --Objectif : Créer un répertoire racine / vide et accessible par n'importe qui
   --Paramètres : root in out, type file
   --Pré : pas de répertoire racine créé
   --Post : un répertoire racine créé
   --Test : être en mesure de se déplacer dans le répertoire racine avec cd une fois le répertoire racine créé
    procedure initRacine (root: in out file);

   --Nom : getCurrentFile (pwd)
   --Objectif : Retourner le chemin absolu du fichier actuelle
   --Paramètres : current_file in, type P_file
   --Pré : current_file existe dans le sgf
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   function getCurrentFile(actual_file : in P_file) return Unbounded_String;

   --Nom : changeSize
   --Objectif : Change la taille du fichier 
   --Paramètres : size in, type Integer, modified_file in , type File
   --Pré : current_filemodified_file existe dans le sgf et ne dépasse le 1 Terra
   --Post : la taille du fichier est changée
   --Test : la taille du fichier est bien modifiée et égale à la taille+10 ko
   procedure changeSize(size : in Integer; modified_file : in File);

   --Nom : display_file_content (ls)
   --Objectif : afficher tous le contenus du repertoire actuel
   --Paramètres : current_file in, type P_file, path in , type string
   --Pré : current_file existe dans le sgf
   --Post : tout le contenu s'affiche
   --Test : tout s'affiche à l'écran après l'appel de la fonction
   function display_file_content(path : in String ; folder : in File) return Unbounded_String;

   --Nom : display_file_all (ls -r)
   --Objectif : afficher tous le contenus du repertoire actuel et des répertoire qu'il contient 
   --Paramètres : current_file in, type P_file, path in , type string
   --Pré : current_file existe dans le sgf
   --Post : tout le contenu du fichier s'affiche et ses contenants aussi
   --Test : tout s'affiche à l'écran après l'appel de la fonction
   function display_file_all(path : in String ; folder : in File) return Unbounded_String; --recursif de l'autre

   --Nom : rename_or_move (rm)
   --Objectif : change le nom ou déplace le fichier
   --Paramètres : modified_file in, type P_file
   --Pré : modified_file existe dans le sgf
   --Post : le fichier est changé de place ou renommé
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   procedure rename_or_move( modified_file : in File);

   --Nom : getCurrentFile (pwd)
   --Objectif : Retourner le chemin absolu du fichier actuelle
   --Paramètres : current_file in out, type P_file
   --Pré : current_file existe dans le sgf
   --Post : le chemin absolu du fichier actuel est retourné
   --Test : être en mesure de retourner l'adressse absolue d'un repertoire créé.
   procedure copy_file_or_folder (copied : in File; path : in String);

end SGF;