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
   begin

      if current_directory = null then
         return null;
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

         begin

            -- Gestion des segments vides : on refuse un chemin de type /exemple1//exemple2
            if Segment = "" then
               if Reste = "" then -- ce cas représente un / final
                  return current_directory;
               else -- c'est le cas d'un //
                  raise VOID_INVALID_PATH;
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
                  raise VOID_INVALID_PATH;
               elsif Reste /= "" and then not Prochain.isRepo then
                  raise VOID_INVALID_PATH with "Pas un répertoire.";
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

----------------------------------------------------------------------------------------------------

   --  function extractParent(fichier: in String; current_directory: in P_file) return P_file is

   --     Last_Slash : Integer := 0;
   --     EMPTY_STRING: Exception;
   --     FILE_NOT_EXIST: Exception;

   --  begin

   --     --Recherche du cas où le string est vide
   --     if fichier'Length = 0 then
   --        raise EMPTY_STRING;
   --     end if;

   --     --Recherche du dernier slash pour isoler le chemin du parent
   --     Last_Slash := Ada.Strings.Fixed.Index (Source => fichier, Pattern => "/", Going => Ada.Strings.Backward);

   --     --Analyse selon la position du slash
   --     if Last_Slash = 0 then
   --        --cas : file (pas de slash), "." ou ".."
   --        if fichier = "." then --parent du courant
   --           return current_directory.rep_parent;
   --        elsif fichier = ".." then --grand-parent du courant
   --           if current_directory.rep_parent = null then
   --              return current_directory;
   --           else
   --              return current_directory.rep_parent.all.rep_parent;
   --           end if;
   --        else
   --           -- "file", son parent est le répertoire courant
   --           return current_directory;
   --        end if;
   --     elsif Last_Slash = fichier'Last then
   --     --cas : "dossier/" ou "./" etc, on retire le slash final et on recommence
   --        return extractParent(fichier(fichier'First.. fichier'Last-1), current_directory);
   --     elsif Last_Slash = fichier'First then
   --        --cas : /file, le parent est la racine
   --        return findRoot(current_directory);
   --     else
   --        --cas "/dir1/dir2/file" ou "dir1/dir2/file"
   --        declare
   --           --Extraction de tout ce qui précède le dernier slash
   --           Path_Parent : constant String := fichier(fichier'First..Last_Slash);
   --           Parent_File : P_file;
         
   --        begin

   --           --Utilisation de parsePath pour obtenir l'adresse
   --           Parent_File := parsePath(Path_Parent, current_directory);
   --           --Recherche d'exception
   --           if Parent_File = null then
   --              raise FILE_NOT_EXIST;
   --           end if;

   --           return Parent_File;

   --        end; 
   --     end if;
   --  end extractParent;

function extractParent (fichier : in String; current_directory : in P_file) return P_file is
   
   Last_Slash : Integer := 0;
   FILE_NOT_EXIST: Exception;
   EMPTY_STRING: Exception;

begin
   -- 1. Sécurité
   if fichier'Length = 0 then
      raise EMPTY_STRING;
   end if;

   -- 2. Recherche du dernier slash
   Last_Slash := Ada.Strings.Fixed.Index
     (Source  => fichier,
      Pattern => "/",
      Going   => Ada.Strings.Backward);

   -- 3. Logique de décision
   if Last_Slash = 0 then
      -- Cas : "fichier", ".", ".." 
      -- Il n'y a pas de slash, donc le parent est par définition 
      -- l'endroit où l'on se trouve (ou le parent de l'endroit où l'on se trouve pour "..")
      
      if fichier = "." then
         return current_directory.rep_parent; -- Le parent du courant
      elsif fichier = ".." then
         -- Le parent du parent
         if current_directory.rep_parent = null then
            return current_directory; 
         else
            return current_directory.rep_parent.rep_parent;
         end if;
      else
         -- C'est un simple nom "readme.txt", son parent est ici
         return current_directory;
      end if;

   elsif Last_Slash = fichier'Last then
      -- Cas : "dossier/" ou "./" ou "../"
      -- On retire le slash final et on recommence (récursion)
      return extractParent(fichier(fichier'First .. fichier'Last - 1), current_directory);

   else
      -- Cas : "./fichier", "../dossier/test", "/a/b/c"
      -- On extrait tout ce qui est AVANT le dernier slash
      declare
         Path_Parent : constant String := fichier(fichier'First .. Last_Slash - 1);
         -- Si Path_Parent devient vide (cas de "/fichier"), c'est la racine
         Final_Path  : constant String := (if Path_Parent = "" then "/" else Path_Parent);
         Resultat    : P_file;
      begin
         -- On laisse parsePath faire tout le travail (gestion du . et .. incluse)
         Resultat := parsePath(Final_Path, current_directory);
         
         if Resultat = null then
            raise FILE_NOT_EXIST;
         end if;
         return Resultat;
      end;
   end if;

end extractParent;

--------------------------------------------------------------------------------------------------

   function findChild(children_list : in List; child_to_find : in String) return P_file is
   begin

      if children_list.Is_Empty then 
         return null;
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

--------------------------------------------------------------------------------------

   --  procedure removeFile (fichier: in String; current_directory: in out P_file) is

   --     temp: P_file;

   --  begin

   --     temp := parsePath(fichier, current_directory);
      

   --  end removeFile;

--------------------------------------------------------------------------------------

   --  procedure renameOrMove(source_file: in String; new_file: in String; current_directory: in P_file) is

   --     temp_source: P_file;
   --     temp_new: P_file;

   --     parent_source : P_file;
   --     parent_new : P_file;

   --  begin

   --     --Le but est d'extraire le répertoire parent souhaité
   --     temp_source := parsePath(source_file, current_directory);
   --     temp_new := parsePath(new_file);

   --     parent_source := extractParent(source_file, current_directory);
   --     parent_new := extractParent(new_file, current_directory);

   --     if getExisting (source_file, current_directory) then
   --        if parent_source = parent_new then --cas du renommage
   --           temp_source.nom := To_String(getName(source_file));
   --        else --cas du déplacement

            

   --  end renameOrMove;

---------------------------------------------------------------------------------------

   function getName(path: in String) return unbounded_string is

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

---------------------------------------------------------------------------------------

   function containsSlash(Text : in String) return Boolean is
   begin

         return (Ada.Strings.Fixed.Index(Text, "/") > 0);
   
   end containsSlash;

---------------------------------------------------------------------------------------

   function getExisting (fichier : in String; current_directory : in P_file) return Boolean is
   begin

      return parsePath(fichier, current_directory) /= null;
   
   exception

      when VOID_INVALID_PATH | EMPTY_STRING | INVALID_FIRST_CHAR =>
         return False;

   end getExisting;

-------------------------------------------------------------------------------------------

   procedure putExisting (fichier: in String; current_directory: in P_file) is
   begin

      if getExisting (fichier, current_directory) then
         Put_Line(fichier & " existe bien.");
      else
         Put_Line (fichier & " n'existe pas.");

      end if;

   end putExisting;

-------------------------------------------------------------------------------------------

   --  procedure menuChoice (racine: in P_file; current_directory: in out P_file) is

   --     choice: Integer;

   --  begin

   --     loop

   --        New_Line;
   --        Put_Line("---Choice of the menu---");
   --        Put_Line("1. Interactive menu");
   --        Put_Line("2. CLI menu");
   --        Put_Line("3. Leave");

   --        begin
   --           Get(choice);
   --           Skip_Line;
   --        exception
   --           when others =>
   --              Skip_Line;
   --              choice := 0; --permet d'éviter les DATA_ERROR
   --        end;
      
   --        case choice is
   --           when 1 => 
   --              interactiveMenu (current_directory);
   --           when 2 => 
   --              cliMenu (current_directory);
   --           when 3 => 
   --              Put("Leaving the program");
   --           when others =>
   --              Put("Invalid choice, please enter a correct value");
   --        end case;

   --     exit when choice = 3;
   --     end loop;
   
   --  end menuChoice;
-------------------------------------------------------------------------------------------

   procedure copy_file(path : in String ; copied_name : in String; current_dir : P_file ) is

      parent : P_file;
      to_be_copied : P_file;
      children_list_current : P_list;

   begin

      children_list_current := getChildren(current_dir);
      to_be_copied := findChild(children_list_current.all, copied_name);
      displayFile (to_be_copied);

      parent := extractParent(path, current_dir);
      SGF.current_directory := parent;
      createFile (To_String(to_be_copied.nom), to_be_copied.isRepo);
      displayFile (SGF.current_directory);
      SGF.current_directory := current_dir;
      displayFile (SGF.current_directory);

   end copy_file;

-------------------------------------------------------------------------------------------

   procedure interactiveMenu(racine: in P_file; current_directory: in P_file) is

      choice: Integer;

   begin

      loop
         New_Line;
         Put_Line("---File Management System---");
         Put_Line("You are currently in " & Put(To_String(getCurrentPath)));
         Put_Line("1. Create a file (mkdir or touch)");
         Put_Line("2. Change directory (cd)");
         Put_Line("3. Delete a file (rm or rm -r)");
         Put_Line("4. Move or rename a file (mv)");
         Put_Line("5. Change the space taken by a file (non-directory)");
         Put_Line("6. Display the files in directory (ls)");
         Put_Line("7. Leave");
         Put_Line("---Enter your choice---");
      exit when choice = 7;
      end loop;

      begin

         Get(choice);
         Skip_Line;
         exception
            when others =>
               Skip_Line;
               choice := 0;
      end;

      case choice is
         when 1 =>
            menuCreate(current_directory);


--------------------------------------------------------------------------------------------------------------

   procedure menuCreate(current_directory: in P_file) is

      name: Unbounded_String;
      isDir: Character;

   begin

      loop
         Put_Line("Please enter the desired file path :");
         name := To_Unbounded_String(Get_Line);
         exit when getPathValidity(To_String(name));
         Put_Line("Invalid path, please try again");
      end loop;

      loop
         Put_Line("Is it a directory? y/n");
         Get(isDir);
         exit when isDir = 'y' or isDir = 'n';
         Put_Line("Please enter one of the specified characters");
      end loop;
      if isDir = 'y' then
         createFile(To_String(name), True);
      else 
         createFile(To_String(name), False);
      end if;

   end menuCreate;
      
-------------------------------------------------------------------------------------------------------------

function getPathValidity (path : in String) return Boolean is
   
   function isValidChar(C : in Character) return Boolean is
   begin
      return (Is_Alphanumeric(C) or C = '.' or C = '_' or C = '-' or C = '/');
   end isValidChar;

   finish        : Integer;
   start         : Integer;
   segment_count : Integer := 0;

begin
   -- 1. Vérification de la taille
   if path'Length = 0 then
      return False;
   end if;

   -- 2. Vérification des caractères et des doubles slashes
   for i in path'Range loop
      if not isValidChar(path(i)) then
         return False;
      end if;
      
      -- Interdiction de "//" pour éviter les segments vides ambigus
      if i < path'Last and then path(i) = '/' and then path(i+1) = '/' then
         return False;
      end if;
   end loop;

   -- 3. Analyse par segments
   start := path'First;
   -- Si le chemin est absolu, on commence l'analyse après le premier '/'
   if path(start) = '/' then
      start := start + 1;
   end if;

   while start <= path'Last loop
      segment_count := segment_count + 1;
      
      -- Trouver la fin du segment (prochain '/' ou fin de chaîne)
      finish := start;
      while finish <= path'Last and then path(finish) /= '/' loop
         finish := finish + 1;
      end loop;

      declare
         -- Extraction du segment
         segment : constant String := path(start .. finish - 1);
      begin
         -- On autorise "." et ".." partout, donc pas de vérification de position.
         
         -- Seule restriction sur le contenu du segment :
         -- Interdiction des segments constitués uniquement de "-" ou "_"
         if segment = "-" or segment = "_" then
            return False;
         end if;
         
         -- Note : Les fichiers cachés (ex: ".bashrc") ou les noms 
         -- contenant ces caractères (ex: "my-file_1") sont autorisés.
      end; 

      start := finish + 1;
   end loop;

   return True;
end getPathValidity;

------------------------------------------------------------------------------------------------------

   procedure testGetPathValidity(isValid: in Boolean) is
   begin

      if isValid = True then
         Put_Line("The path is correct");
      else
         Put_Line("The past isn't correct.");
         Put_Line("- and _ can't make a whole segment. Only alphanumerical values are allowed.");
      end if;
   
   end testGetPathValidity;


end SGF;