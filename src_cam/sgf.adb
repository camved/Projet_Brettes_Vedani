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

   function getCurrentPath(actual_file : in P_file) return Unbounded_String is

   begin

      if current_file = null then
         raise VOID_POINTER_ERROR with "Error : no current file";
      end if;
      if current_file.Rep_Parent = null then
         return;
      elsif current_file.Rep_Parent = null then
         return "/" & current_file.Nom;
      else
         return getCurrentPath(currrent_file.Rep_Parent) & "/" & current_file.Nom;
      end if;
   end getCurrentPath;


end SGF;