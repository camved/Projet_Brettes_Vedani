with SGF;
with Ada.Strings.Fixed; 
with Ada.Strings;

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
      
procedure createFile (nom_or_path: in String; isRepo : in Boolean) is
      pointer_created : P_file;
      nom : Unbounded_String;
      
      Target_Parent : P_file; 
      Last_Slash : Natural;

   begin
      
      if containsSlash(nom_or_path) then
         Last_Slash := Ada.Strings.Fixed.Index(nom_or_path, "/", Going => Ada.Strings.Backward);
         
         if Last_Slash = nom_or_path'First then
            Target_Parent := parsePath("/", SGF.current_directory);
         else
            Target_Parent := parsePath(nom_or_path(nom_or_path'First .. Last_Slash - 1), SGF.current_directory);
         end if;
         
         nom := To_Unbounded_String(nom_or_path(Last_Slash + 1 .. nom_or_path'Last));
         
      else
         
         Target_Parent := SGF.current_directory;
         nom := To_Unbounded_String(nom_or_path);
      end if;

      pointer_created := new file;
      pointer_created.nom := nom;
      pointer_created.droits_acces := "rwxrwxrwx";
      pointer_created.taille := 1;
      
      pointer_created.rep_parent := Target_Parent; 
      
      pointer_created.isRepo := isRepo;

      if isRepo then
         pointer_created.L_enfant := new File_List_Pkg.List; 
      else
         pointer_created.L_enfant := null; 
      end if;

      if pointer_created.rep_parent.L_enfant = null then
          Put_Line("Erreur : Le chemin de destination n'est pas un dossier valide.");
      else
          pointer_created.rep_parent.L_enfant.Append(pointer_created);
      end if;

      displayFile (pointer_created);


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
         return parent_path & pwd_file.Nom & "/"  ;
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
         if file_to_show.isRepo then
            Put_Line(Count_Type'Image(file_to_show.L_enfant.Length));
         else
            Put_Line("File (no children)");
         end if;

         Put("Parent           : ");
         if file_to_show.rep_parent /= null then
               
            if To_String(file_to_show.rep_parent.nom) = "" then
               Put_Line("root"); 
            else
               Put_Line(To_String(file_to_show.rep_parent.nom));
            end if;

         else
            Put_Line("No parents");
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

   ----------

      function  parseRelative (fichier: in String; current_directory: in P_file) return P_file is

      First_Slash : Integer := 0; --permet de gérer l'avancée du découpage

   begin

      -- cas : fin de parcours 
      if fichier'Length = 0 then -- VITAL POUR LA RECURSION
         return current_directory;
      end if;

      -- recherche du prochain /
      -- instanciation avec de la généricité de la recherche du /
      First_Slash := Ada.Strings.Fixed.Index(Source => fichier, Pattern => "/");

      -- découpage du segment actuel
      declare
         --cette partie différencie les cas possibles et initialise des variables en fonction de la position du /
         Segment : constant String := (if First_Slash = 0 then (fichier) else (fichier(fichier'First .. First_Slash - 1)));

         Reste: constant String := (if First_Slash = 0 then "" else fichier(First_Slash+1.. fichier'Last));

         Prochain : P_file;

         VOID_INVALID_PATH: exception;
         VOID_ROOT_LOCATION: exception;

         begin

            -- Gestion des segments vides : on refuse un chemin de type /exemple1//exemple2
            if Segment = "" then
               if Reste = "" then -- ce cas représente un / final
                  return current_directory;
               else -- c'est le cas d'un //
                  raise VOID_INVALID_PATH with "Erreur : double slash interdit";
               end if;
   
            -- cas : répertoire courant = "."
            elsif Segment = "." then
               return parseRelative(Reste, current_directory);

            -- cas : répertoire parent = ".."
            elsif Segment = ".." then
               if current_directory.rep_parent = null then -- cas où on est à la racine
                  raise VOID_ROOT_LOCATION with "Erreur : vous essayez de monter au dessus de la racine";
               else
                  return parseRelative(Reste, current_directory.rep_parent);
               end if;
            
            -- cas général
            else

               Prochain := findChild(current_directory.L_enfant.all, Segment);

               if Prochain = null then
                  raise VOID_INVALID_PATH with "Erreur : le chemin demandé n'existe pas";
               elsif Reste /= "" and then not Prochain.isRepo then
                  raise VOID_INVALID_PATH with "Erreur : c'est un fichier";
               else
                  return parseRelative(Reste, Prochain);
               end if;
            end if;
         end;

   end parseRelative;

   ----------

   function parseAbsolute (fichier: in String; current_directory: in P_file) return P_file is

      tempDir: P_file; --doit prendre la valeur de la racine au début

   begin

      tempDir := findRoot(current_directory);
      if fichier'Length > 1 then
         declare
            -- extrait la partie après le / initial
            Reste : constant String := fichier(fichier'First + 1..fichier'last);
         
         begin

            return parseRelative (Reste, tempDir);
         
         end;
      else -- le chemin est juste "/"
         return tempDir;
      end if;

   end parseAbsolute;

   ----------

   function findRoot (current_directory: in P_file) return P_file is

      VOID_POINTER_ERROR: exception;

   begin

      if current_directory = null then
         raise VOID_POINTER_ERROR;
      elsif current_directory.all.rep_parent = null then
         return current_directory;
      else
         return findRoot(current_directory.all.rep_parent);
      end if;
   
   end findRoot;

   ----------

   function parsePath (fichier: in String; current_directory: in P_file) return P_file is

      EMPTY_STRING: Exception;
      INVALID_FIRST_CHAR: Exception;
      firstSlash: Integer := 0;

   begin
   
      if fichier'Length = 0 then
         raise EMPTY_STRING;
      else
         if fichier(fichier'First) = '/' then
            return(parseAbsolute(fichier, current_directory)); 
         elsif (fichier(fichier'First) = '.') or Is_Letter (fichier(fichier'First)) then
            return(parseRelative(fichier, current_directory));
         else
            raise INVALID_FIRST_CHAR;
         end if;
      end if;

   end parsePath;

   ----------

   function containsSlash(Text : in String) return Boolean is
   begin
      return (Ada.Strings.Fixed.Index(Text, "/") > 0);
   end containsSlash;

   ----------

   function getName(path : String) return unbounded_string is

      last_Slash_Index : Natural;

      begin

         if containsSlash(path) then 
            last_Slash_Index := Ada.Strings.Fixed.Index(
               Source  => path, 
               Pattern => "/", 
               Going   => Ada.Strings.Backward
            );
            return To_Unbounded_String(path(last_Slash_Index + 1 .. path'Last));

         else 
            return(To_Unbounded_String(path));
         end if;
      end getName;


end SGF;