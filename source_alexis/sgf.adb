package body SGF is

   root: file;
   current_directory : P_file;

   procedure initRacine (root: in out file) is
   begin

      root.nom := To_Unbounded_String("");
      root.droits_acces := "rwxrwxrwx";
      root.taille := 1; --Volume total divisé par 10Ko pour qu'on ne manie qu'une unité simple
      root.ID := root'Address;
      root.rep_parent := null;
      root.L_enfant := new File_List_Pkg.List;
      root.isRepo := True;
      

   end initRacine;

   procedure createFile (nom: in String; created: out file; isRepo : in Boolean) is
      pointer_created : P_file;
   begin
   pointer_created := new file;
   pointer_created.nom := To_Unbounded_String(nom);
   pointer_created.droits_acces := "rwxrwxrwx";
   pointer_created.taille := 1;
   pointer_created.rep_parent := SGF.current_directory;
   pointer_created.L_enfant := null;
   pointer_created.isRepo := isRepo;

   if isRepo then
      pointer_created.L_enfant := new File_List_Pkg.List; -- Liste reste vide tant que pas d'enfant et répertoire
   else
      pointer_created.L_enfant := null; -- si fichier
   end if;

   SGF.File_List_Pkg.Append(SGF.current_directory.L_enfant.all, pointer_created);

   created := pointer_created.all;

   end createFile;



   --  procedure changePwd (fichier: in String; current_file : in out String) is
   
   --     cible: file;

   --  begin
   
   --     if fichier'Length > 0 then
   --        if fichier(fichier'First) = '/' then
            
   --        elsif (fichier(fichier'First) >= 'A' and fichier(fichier'First) <= 'z') or (fichier(fichier'First) = '.') then

   --  end changePwd;

end SGF;
