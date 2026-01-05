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

end SGF;

