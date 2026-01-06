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

   function getActualPath(actual_file : in P_file) return Unbounded_String is

   begin

      if actual_file = null then
         raise VOID_POINTER_ERROR with "Error : no current file";
      end if;
      if actual_file.Rep_Parent = null then
         return To_Unbounded_String("/");
      elsif actual_file.Rep_Parent.Rep_Parent = null then
         return "/" & actual_file.Nom;
      else
         return getActualPath(actual_file.Rep_Parent) & "/" & actual_file.Nom;
      end if;
   end getActualPath;


end SGF;