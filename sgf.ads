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

   --Nom : initRacine
   --Objectif : Créer un répertoire racine / vide et accessible par n'importe qui
   --Paramètres : root in out, type file
   --Pré : pas de répertoire racine créé
   --Post : un répertoire racine créé
   --Test : être en mesure de se déplacer dans le répertoire racine avec cd une fois le répertoire racine créé
   procedure initRacine (root: in out file);

   --Nom : createFile
   --Objectif : Créer un fichier dont on choisit le nom, les droits et le type (répertoire ou fichier simple) à l'endroit de notre choix.
   --Paramètres :
   --Pré : pas de fichier appelé pareil créé à cet endroi
   --Post : répertoire parent est bien un répertoire (file.rep_parent.all.isRepo = True)
   procedure createFile (pwd: in out file; created: out file);

end SGF;

