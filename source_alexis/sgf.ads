with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with System;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Ada.Containers.Doubly_Linked_Lists;

package SGF is 

   type file; --Déclaration partielle pour permettre le pointeur suivant

   type P_file is access file; 

   package File_List_Pkg is new Ada.Containers.Doubly_Linked_Lists (Element_Type => P_file);

   type P_Liste_Enfants is access File_List_Pkg.List;

   type file is record

      nom: unbounded_string;
      droits_acces: String (1..9);
      taille: Integer;
      rep_parent: P_file;
      ID: System.Address;
      L_enfant : P_Liste_Enfants;
      isRepo: Boolean;
   
   end record;

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
   procedure createFile (nom: in String; created: out file; isRepo : in Boolean);

   --Nom : createRepo
   --Objectif : Créer un répertoire dont on choisit le nom et les droits à l'endroit de notre choix.createFile (pwd : in out file, created : out file)
   --Paramètres : 
   --Pré : pas de répertoire appelé pareil créé dans le répertoire père
   --Post :
      -- répertoire parent est bien un répertoire (file.rep_parent.all.isRepo = True)
      -- répertoire fils bien créé et conforme à ce qui est demandé
   --  procedure createRepo (repo: in out file);

   --  --Nom : removeFile
   --  --Objectif : Supprimer un fichier existant et supprime récursivement tout son contenu selon l'appel fait
   --  --Paramètre : 
   --     -- fichier : in string
   --  --Pré : fichier existant
   --  --Post : 
   --     -- répertoire père du fichier ne contient plus le fichier
   --     -- SI APPEL AVEC -r LES FICHIERS ET REPERTOIRES CONTENUS SONT SUPPRIMES
   --  --Test : afficher le contenu du répertoire père
   --  procedure removeFile (fichier: in String);

   --  --Nom : getFileID
   --  --Objectif : Renvoie le pointeur caractérisant un fichier cherché à partir d'un string
   --  --Paramètre :
   --     -- fichier : in String
   --     -- address : out String
   --     -- isRepo : out Boolean
   --  --Pré : fichier existant
   --  --Post : Adresse pointe sur le fichier
   --  function getFileID (fichier: in String; address: out System.Address; isRepo: out Boolean) return Boolean;

   --  --Nom : changePwd
   --  --Objectif : Déplacer le pwd vers le répertoire demandé
   --  --Paramètre : 
   --     -- fichier : in String
   --  -- Pré : 
   --     -- répertoire existant
   --     -- isRepo = True
   --  -- Post : current_repo = adresse du fichier cherché
   --  procedure changePwd (fichier: in String; current_file: in out String);

   --  --Nom : parsePath
   --  --Objectif : Renvoyer l'adresse du répertoire ou du fichier visé
   --  --Paramètre :
   --     -- fichier : in String
   --     -- ID : out Address
   --  --Pré : 
   --     --Adresse valide rentrée

end SGF;

