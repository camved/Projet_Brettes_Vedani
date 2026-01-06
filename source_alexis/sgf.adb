package body SGF is

   root: file;

   procedure initRacine (root: in out file) is
   begin

      root.nom := To_Unbounded_String("");
      root.droits_acces := "rwxrwxrwx";
      root.taille := 1; --Volume total divisé par 10Ko pour qu'on ne manie qu'une unité simple
      root.ID := root'Address;
      root.rep_parent := null;
      root.L_enfant := null;
      root.isRepo := True;

   end initRacine;

   procedure createFile (nom: in out String; created: out file) is
   begin
   
   end createFile;

end SGF;