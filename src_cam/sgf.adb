package body SGF is


   root: file;
   current_directory : P_file;

   ----------

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

   ----------
      
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

   ----------

   function getCurrentPath(pwd_file : in P_file) return Unbounded_String is
   
      parent_path : Unbounded_String;

   begin
      if pwd_file = null then
         raise VOID_POINTER_ERROR with "Error : file is null";
      end if;
      if pwd_file.Rep_Parent = null then
         return To_Unbounded_String("/");
      
      else
         parent_path := getCurrentPath(pwd_file.Rep_Parent);
         return parent_path & "/" & pwd_file.Nom;
      end if;
   end getCurrentPath;

   ----------

   function getChildren(adress_file : in P_file) return P_list is 

      begin
      if adress_file.all.L_enfant.Is_Empty then 
         raise VOID_CHILD_ERROR with "Error : no child in this directory";
      else 
         return adress_file.all.L_enfant;
      end if;

   end getChildren;
 
   ----------

   function findChild(children_list : in List; child_to_find : in String) return P_file is

   begin
      if children_list.Is_Empty then 
         raise VOID_CHILD_ERROR with "Error : no child in this directory";
      else
         for child_element of children_list loop
            if To_String(child_element.nom) = child_to_find then
               return child_element;
            end if;
         end loop;
         return null;
      end if;
   end findChild;

   ----------

   function getCurrentDirectory return P_file is

   begin
      return current_directory;
   end getCurrentDirectory;

   ----------

   procedure changeDirectory(name_file_to_go : in String) is

      current : P_file;
      next_dir : P_file;

      begin
         current := SGF.current_directory;
         next_dir := SGf.findChild(current.L_enfant.all, name_file_to_go);

         if next_dir = null then 
            raise NOT_IN_THIS_DIRECTORY with "Error : no such directories in this directory";
         elsif not(next_dir.isRepo) then
            raise NOT_A_DIRECTORY with "Error : not a directory";
         else
            SGF.current_directory := next_dir;
         end if; 


      end changeDirectory;
      
   ----------

   procedure displayFile(file_to_show : in P_file) is
      begin
         
         if file_to_show = null then
            Put_Line("Erreur : Le fichier à afficher est null.");
            return;
         end if;

         New_Line;

         
         Put("Type             : ");
         if file_to_show.isRepo then
            Put_Line("d (F)"); 
         else
            Put_Line("- (Fichier)"); 
         end if;

         Put_Line("Access Right     : " & file_to_show.droits_acces);

         Put_Line("Size             : " & Integer'Image(file_to_show.taille) & " o");

         Put_Line("File name        : " & To_String(file_to_show.nom));

         Put("Sous répertoires : ");
         if file_to_show.isRepo and then file_to_show.L_enfant /= null then
            Put_Line(Count_Type'Image(file_to_show.L_enfant.Length));
         else
            Put_Line("0 (Non applicable)");
         end if;

         Put("Parent           : ");
         if file_to_show.rep_parent /= null then
      
            Put_Line(To_String(file_to_show.rep_parent.nom));
         else
            Put_Line("");
         end if;
         
         New_Line;

   end displayFile;

   procedure displayFileContent(current_directory : in P_file) is

      children_list : P_list;

      begin

         children_list := getChildren(current_directory);

         for child of children_list.all loop
            Put_Line(To_String(child.nom));
         end loop;

   end displayFileContent;

end SGF;