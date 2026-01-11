package body sgf is

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

------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------

   procedure createFile (nom: in String; isRepo : in Boolean) is

      pointer_created : P_file;
   
   begin
   
      pointer_created := new file;
      pointer_created.nom := To_Unbounded_String(nom);
      pointer_created.droits_acces := "rwxrwxrwx";
      pointer_created.taille := 1;
      pointer_created.rep_parent := current_directory;
      pointer_created.L_enfant := null;
      pointer_created.isRepo := isRepo;

      if isRepo then
         pointer_created.L_enfant := new File_List_Pkg.List; -- Liste reste vide tant que pas d'enfant et rÃ©pertoire
      else
         pointer_created.L_enfant := null; -- si fichier
      end if;

      pointer_created.rep_parent.all.L_enfant.all.Append(pointer_created);

   end createFile;

--------------------------------------------------------------------------------------------------

   procedure changeDirectory(name_file_to_go : in String) is

      current : P_file;
      next_dir : P_file;
      NOT_IN_THIS_DIRECTORY: exception;
      NOT_A_DIRECTORY: exception;

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

---------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------

   function findChild(children_list : in List; child_to_find : in String) return P_file is
   
      VOID_CHILD_ERROR: exception;

   begin

      if children_list.Is_Empty then 
         raise VOID_CHILD_ERROR;
      else
         for child_element of children_list loop
            if To_String(child_element.all.nom) = child_to_find then
               return child_element;
            end if;
         end loop;

         return null;
      end if;

   end findChild;

---------------------------------------------------------------------------------------------------

   function getCurrentPath(pwd_file : in P_file) return Unbounded_String is
   
      parent_path: Unbounded_String;
      VOID_POINTER_ERROR: exception;

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

---------------------------------------------------------------------------------------------------

   function getChildren(adress_file : in P_file) return P_list is 

      VOID_CHILD_ERROR: exception;

      begin
      if adress_file.all.L_enfant.Is_Empty then 
         raise VOID_CHILD_ERROR with "Error : no child in this directory";
      else 
         return adress_file.all.L_enfant;
      end if;

   end getChildren;

----------------------------------------------------------------------------------------------------

   procedure displayFile(current_directory : in P_file) is
   begin
      
      if current_directory = null then
         Put_Line("Erreur : Le fichier à afficher est null.");
         return;
      end if;

      New_Line;
      
      Put("Type             : ");
      if current_directory.isRepo then
         Put_Line("d (Dossier)"); 
      else
         Put_Line("- (Fichier)"); 
      end if;
      Put_Line("Access Right     : " & current_directory.droits_acces);
      Put_Line("Size             : " & Integer'Image(current_directory.taille) & " o");
      Put_Line("File name        : " & To_String(current_directory.nom));
      Put("Sous répertoires : ");
      if current_directory.isRepo and then current_directory.L_enfant /= null then
         Put_Line(Count_Type'Image(current_directory.L_enfant.Length));
      else
         Put_Line("0 (Non applicable)");
      end if;
      Put("Parent           : ");
      if current_directory.rep_parent /= null then
         Put_Line(To_String(current_directory.rep_parent.nom));
      else
         Put_Line("[]");
      end if;

      New_Line;

      if (current_directory.L_enfant = null) and (current_directory.isRepo = True) then 
         Put("Pas d'enfants");
      elsif (current_directory.L_enfant /= null) and (current_directory.isRepo = True) then
         
         declare
         
            ma_liste: List renames current_directory.L_enfant.all;
         
         begin
         
            Put_Line("Liste des enfants de "& To_String(current_directory.nom) & " :");
            --Boucle sur chaque élément de la liste avec la bibliothèque Ada.Containers.Doubly_Linked_Lists
            for Element_pointe of ma_liste loop
               if Element_pointe /= null then
                  Put_Line("- " & To_String(Element_pointe.nom));
               end if;
            end loop;

         end;

      end if;

   end displayFile;

-------------------------------------------------------------------------------------

   procedure displayFileContent(current_directory : in P_file) is

      children_list : P_list;

      begin

         children_list := getChildren(current_directory);

         for child of children_list.all loop
            Put_Line(To_String(child.nom));
         end loop;

   end displayFileContent;


end SGF;