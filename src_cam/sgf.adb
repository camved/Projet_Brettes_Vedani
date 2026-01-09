package body SGF is


   root: file;
   current_directory : P_file;

   procedure initRacine (root: in out file) is
      pointer_root : P_file;
   begin
      pointer_root := new file;
      pointer_root.nom := To_Unbounded_String("");
      pointer_root.droits_acces := "rwxrwxrwx";
      pointer_root.taille := 1; --Volume total divisé par 10Ko pour qu'on ne manie qu'une unité simple
      pointer_root.rep_parent := null;
      pointer_root.L_enfant := new File_List_Pkg.List;
      pointer_root.isRepo := True;

      root := pointer_root.all;
      current_directory := pointer_root;
      

   end initRacine;
      
   procedure createFile (nom: in String; isRepo : in Boolean)is
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

   pointer_created.rep_parent.all.L_enfant.all.Append(pointer_created);

   end createFile;

   function getCurrentPath(pwd_file : in P_file) return Unbounded_String is

   begin

      if current_directory = null then
         raise VOID_POINTER_ERROR with "Error : no current file";
      end if;
      if pwd_file.Rep_Parent = null then
         return pwd_file.nom;
      elsif SGF.current_directory.all.Rep_Parent = null then
         return To_Unbounded_String ("/");
      else
         return getCurrentPath(SGF.current_directory.all.Rep_Parent) & "/" & pwd_file.Nom;
      end if;
   end getCurrentPath;

   function getChildren(adress_file : in P_file) return P_list is 

   begin
   if adress_file.all.L_enfant.Is_Empty then 
      raise VOID_CHILD_EROOR with "Error : no child in this directory";
   else 
      return adress_file.all.L_enfant;
   end if;

   end getChildren;
 


   function findChild(children_list : in List; child_to_find : in String) return P_file is

   begin
      if children_list.Is_Empty then 
         raise VOID_CHILD_EROOR with "Error : no child in this directory";
      else
         for child_element of children_list loop
            if To_String(child_element.all.nom) = child_to_find then
               return child_element;
            else 
               return null;
            end if;
         end loop;

         return null;
      end if;
   end findChild;

   function get_current_directory return P_file is
   begin
      return current_directory;
   end get_current_directory;

end SGF;