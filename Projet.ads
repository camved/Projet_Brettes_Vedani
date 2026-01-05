package SGF is 

   type P_file is access file;

   type file is record

      nom: String;
      droit_acces: String (1..9);
      taille: Integer;
      rep_parent: P_file;
      L_enfant: P_file;
      isRepo: Boolean;
   
   end record;

   procedure initRacine (root: in out file) is

      nom := "/";
      droit_access := "rwxrwxrwx"
      taille := 1; --Volume total divisé par 10Ko pour qu'on ne manie qu'une unité simple
      



end SGF;

