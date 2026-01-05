package body SGF is

   root: file;

   procedure initRacine (root: in out file) is
   begin

      root.nom := To_Unbounded_String("/");
      root.droits_acces := "rwxrwxrwx";
      root.taille := 1; --Volume total divisé par 10Ko pour qu'on ne manie qu'une unité simple
      root.rep_parent := null;
      root.L_enfant := null;
      root.isRepo := True;

   end initRacine;

   function getActualFile(actual_file : in P_file) return Unbounded_String is
      actual_path : Unbounded_String ;
      rep_parent : file ;
   begin
      rep_parent := file ;
      if root.rep_parent = null then
         actual_path := "/";
      else
         P_file;   
      end if;
   end getActualFile;

end SGF;