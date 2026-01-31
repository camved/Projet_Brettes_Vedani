with sgf;
with memoire;

package body sgf is

   ----------

   procedure Free is new Ada.Unchecked_Deallocation(Object => file, Name => P_file);

   type Resultat_Regex is record
      Existe  : Boolean := False;
      Index   : Natural := 0;
      pattern : Unbounded_String := To_Unbounded_String(""); 
   end record;

   ----------

   function getCurrentDirectory return P_file is
   begin

      return sgf.current_directory;

   end getCurrentDirectory;

   ----------

   function containsRegex (name : String) return Resultat_Regex is
      Resultat : Resultat_Regex;
   begin
      for I in name'Range loop
         if name(I) = '*' or name(I) = '?' then
            Resultat.Existe  := True;
            Resultat.Index   := I;
            return Resultat;
         end if;
      end loop;
      return Resultat;
   end containsRegex;

   ----------

   function Match_Pattern(FileName : String; Pattern : String) return Boolean is
   begin
      if Pattern'Length = 0 then
         return FileName'Length = 0;
      end if;

      -- commence par '*'
      if Pattern(Pattern'First) = '*' then
         if Pattern'Length = 1 then
            return True;
         end if;
         
         if Match_Pattern(FileName, Pattern(Pattern'First + 1 .. Pattern'Last)) then
            return True;
         elsif FileName'Length > 0 then
             return Match_Pattern(FileName(FileName'First + 1 .. FileName'Last), Pattern);
         else
             return False;
         end if;

      -- commence par '?'
      elsif Pattern(Pattern'First) = '?' then
         if FileName'Length = 0 then
            return False;
         else
            return Match_Pattern(FileName(FileName'First + 1 .. FileName'Last), 
                                 Pattern(Pattern'First + 1 .. Pattern'Last));
         end if;

      else
         if FileName'Length > 0 and then FileName(FileName'First) = Pattern(Pattern'First) then
            return Match_Pattern(FileName(FileName'First + 1 .. FileName'Last), 
                                 Pattern(Pattern'First + 1 .. Pattern'Last));
         else
            return False;
         end if;
      end if;
   end Match_Pattern;

   ----------

   function getRegexFiles (pattern : String; current_dir : P_file) return P_list is
      Matches_List : P_list := new File_List_Pkg.List;
      All_Children : P_list;
   begin
      if current_dir.isRepo and then not current_dir.L_enfant.all.Is_Empty then
         All_Children := getChildren(current_dir);

         for Child of All_Children.all loop
            if Match_Pattern(To_String(Child.nom), pattern) then
               Matches_List.Append(Child);
            end if;
         end loop;
      end if;

      return Matches_List;
   end getRegexFiles;

      ----------

   function Collect_Targets(Name_Or_Path : String; Current_Dir : P_file) return P_list is
      Target_List  : P_list := new File_List_Pkg.List;
      Parent_Dir   : P_file;
      Pattern_Name : Unbounded_String;
      Simple_Target : P_file;
   begin
      -- ls ou pwd si pas d'arguments
      if Name_Or_Path = "" or Name_Or_Path = "." then
         Target_List.Append(Current_Dir);
         return Target_List;
      end if;

      -- path
      if containsSlash(Name_Or_Path) then
         Parent_Dir   := extractParent(Name_Or_Path, Current_Dir);
         Pattern_Name := getName(Name_Or_Path);
      else
         Parent_Dir   := Current_Dir;
         Pattern_Name := To_Unbounded_String(Name_Or_Path);
      end if;

      if Parent_Dir = null then return Target_List; end if;

      -- contient des regex ?
      if containsRegex(To_String(Pattern_Name)).Existe then
         return getRegexFiles(To_String(Pattern_Name), Parent_Dir);
      else
         begin
            Simple_Target := findChild(Parent_Dir.L_enfant.all, To_String(Pattern_Name));
            if Simple_Target /= null then
               Target_List.Append(Simple_Target);
            end if;
         exception
            when FILE_NOT_EXIST =>
               null;
         end;
         return Target_List;
      end if;
   exception
      when others => return Target_List; 
   end Collect_Targets;

   ---------- Root Initialization

   procedure initRacine (root: in out P_file; memoire: in out Mem) is
      pointer_root : P_file;
      
   begin

      root := new file;
      root.nom := To_Unbounded_String("/");
      root.droits_acces := sgf.current_user;
      root.taille := 10;
      root.rep_parent := null;
      root.L_enfant := new File_List_Pkg.List;
      root.isRepo := True;
      initMem(memoire);
      root.adress := allocateMem(memoire, root.taille);
      sgf.current_directory := root;
      
   end initRacine;

   ---------- Files and directories initialization/destruction

   function Invariant_SGF (current_root : P_file) return Boolean is
   begin

      return (current_root /= null and then 
            To_String(current_root.nom) = "/" and then 
            current_root.rep_parent = null);
   end Invariant_SGF;
         
   procedure createFile (nom_or_path: in String; isRepo : in Boolean; memoire : in out Mem) is

      -- Précondition : le chemin ne doit pas être vide
      pragma Assert (nom_or_path'Length > 0, "createFile: Le nom ne peut pas etre vide");
      -- Précondition : la mémoire doit être initialisée
      pragma Assert (memoire.first_Element /= null, "createFile: Memoire non initialisee");

      pointer_created : P_file;
      nom : Unbounded_String;
      
      Target_Parent : P_file; 
      Last_Slash : Natural;

      begin

         Target_Parent := extractParent(nom_or_path, SGF.current_directory);

         if containsSlash(nom_or_path) then
            Last_Slash := Ada.Strings.Fixed.Index(nom_or_path, "/", Going => Ada.Strings.Backward);
            
            nom := To_Unbounded_String(nom_or_path(Last_Slash + 1 .. nom_or_path'Last));
         else
            nom := To_Unbounded_String(nom_or_path);
         end if;

         
         pointer_created := new file;
         pointer_created.nom := nom;
         pointer_created.droits_acces := sgf.current_user;
         pointer_created.taille := 10;
         pointer_created.rep_parent := Target_Parent; 
         pointer_created.isRepo := isRepo;
         pointer_created.adress := allocateMem(memoire, pointer_created.taille);
         if isRepo then
            pointer_created.L_enfant := new File_List_Pkg.List; 
         else
            pointer_created.L_enfant := null; 
         end if;

         if pointer_created.rep_parent = null then
            Put_Line("Erreur : Impossible de trouver le dossier parent.");
         elsif pointer_created.rep_parent.L_enfant = null then
            Put_Line("Erreur : La destination '" & To_String(pointer_created.rep_parent.nom) & "' n'est pas un répertoire.");
         else
            pointer_created.rep_parent.L_enfant.Append(pointer_created);
         end if;

         pragma Assert (Invariant_SGF(findRoot(SGF.current_directory)), "Invariant rompu apres creation");

   end createFile;

   ----------

   procedure delete (name_or_path: in String ; current_dir : P_file; memoire: in out Mem) is
      -- Précondition : current_dir ne doit pas être null
      pragma Assert (current_dir /= null, "delete: Le repertoire courant n'existe pas");
      -- Précondition : On ne peut pas supprimer un fichier sans nom 
      pragma Assert (name_or_path'Length > 0, "delete: Le nom du fichier est vide");

      pointer_deleted : P_file; 
      Target_Parent : P_file; 
      C : File_List_Pkg.Cursor;
      Targets : P_list;
      use File_List_Pkg; 
   begin

      Targets := Collect_Targets(name_or_path, current_dir);

      if Targets.Is_Empty then
         Put_Line("Erreur : Aucun fichier trouvé pour '" & name_or_path & "'");
         return;
      end if;

      for Element of Targets.all loop
         pointer_deleted := Element;
         if pointer_deleted.isRepo then
             Put_Line("Erreur : '" & To_String(pointer_deleted.nom) & "' est un dossier. Utilisez rmdir.");
         elsif pointer_deleted.rep_parent = null then
             Put_Line("Impossible de supprimer la racine.");
             
         else
             Target_Parent := pointer_deleted.rep_parent;
             C := File_List_Pkg.Find(Container => Target_Parent.L_enfant.all, Item => pointer_deleted);
             freeMem(memoire, pointer_deleted.adress, pointer_deleted.taille);
             
             if Has_Element(C) then
                Target_Parent.L_enfant.all.Delete(C);
                Free(pointer_deleted); 
             end if;
         end if;
      end loop;

      pragma Assert (Invariant_SGF(findRoot(SGF.current_directory)), "Invariant rompu apres deletion");

   end delete;

   ----------

   procedure deleteDirectory (name_or_path: in String ; current_dir : P_file; memoire : in out Mem) is
      
      target_parent : P_file;
      deleted_to_be : P_file;
      child_cursor : File_List_Pkg.Cursor;
      child_ptr : P_file;
      Targets : P_list;
      use File_List_Pkg; 

   begin
      Targets := Collect_Targets(name_or_path, current_dir);

      if Targets.Is_Empty then
         Put_Line("Error: no directory found for '" & name_or_path & "'");
         return;
      end if;

      for Element of Targets.all loop
   
         deleted_to_be := Element;

         if not deleted_to_be.isRepo then
            Put_Line("Error: '" & To_String(deleted_to_be.nom) & "' is not a directory.");
         
         elsif deleted_to_be.rep_parent = null then
            raise VOID_ROOT_LOCATION with "Deleting the root is not allowed in our programme.";

         else
            while not deleted_to_be.L_enfant.all.Is_Empty loop
               
               child_ptr := deleted_to_be.L_enfant.all.First_Element;
               
               if child_ptr.isRepo then
                  deleteDirectory(To_String(child_ptr.nom), deleted_to_be,memoire); 
               else
                  delete(To_String(child_ptr.nom), deleted_to_be, memoire);
               end if;
            end loop;

            freeMem(memoire, deleted_to_be.adress, deleted_to_be.taille);

            target_parent := deleted_to_be.rep_parent;
            child_cursor := Find(target_parent.L_enfant.all, deleted_to_be);
            
            if Has_Element(child_cursor) then
               target_parent.L_enfant.all.Delete(child_cursor);
               Free(deleted_to_be);
            end if;
            
         end if;
      end loop;



   end deleteDirectory;

   ---------- tools useful in functions or procedure

   function getChildren(adress_file : in P_file) return P_list is 

   pragma Assert (adress_file /= null, "getChildren: L'objet cible ne peut pas etre null");

   begin
      if adress_file.all.L_enfant.Is_Empty then 
         return null;
      else 
         return adress_file.all.L_enfant;
      end if;

   end getChildren;

   ----------

   function findChild(children_list : in List; child_to_find : in String) return P_file is

   pragma Assert (child_to_find'Length > 0, "findChild: Le nom recherche est vide");

   begin
      if children_list.Is_Empty then 
         raise FILE_NOT_EXIST with "Directory is empty";
      else
         for child_element of children_list loop
            if To_String(child_element.nom) = child_to_find then
               return child_element;
            end if;
         end loop;
         raise FILE_NOT_EXIST with child_to_find & "not found.";
      end if;
   end findChild;

   ----------

   procedure displayFile(current_directory : in P_file) is
      use Ada.Containers;
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

      Put_Line("Access Right     : " & To_String(current_directory.droits_acces));
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
         if To_String(current_directory.rep_parent.nom) = "" then
            Put_Line("root"); 
         else
            Put_Line(To_String(current_directory.rep_parent.nom));
         end if;
      else
         Put_Line("No parents (Is Root)");
      end if;
      
      New_Line;

      if current_directory.isRepo then
         
         if current_directory.L_enfant = null or else current_directory.L_enfant.Is_Empty then
            Put_Line("   (Dossier vide)");
         else
            Put_Line("   Contenu de " & (if To_String(current_directory.nom) = "" then "root" else To_String(current_directory.nom)) & " :");
            
            for child of current_directory.L_enfant.all loop
               if child /= null then
                  Put_Line("   - " & To_String(child.nom));
               end if;
            end loop;
         end if;

      end if;

      New_Line;

   end displayFile;

   ----------

   procedure displayOwner(path: in String; current_directory: in P_file) is
   begin

      Put_Line("The owner of "& path & " is:");
      Put_Line(To_String(parsePath(path, current_directory).droits_acces));

   end displayOwner;
   ----------

   function containsSlash(Text : in String) return Boolean is

   begin
      return (Ada.Strings.Fixed.Index(Text, "/") > 0);
   end containsSlash;

   ----------

   function getName(path : in String) return unbounded_string is

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
   
   ----------

   function parseAbsolute (fichier: in String; current_directory: in P_file) return P_file is

      tempDir: P_file;

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
   
   function  parseRelative (fichier: in String; current_directory: in P_file) return P_file is

      First_Slash : Integer := 0; 

   begin

      if fichier'Length = 0 then
         return current_directory;
      end if;

      First_Slash := Ada.Strings.Fixed.Index(Source => fichier, Pattern => "/");

      declare
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
               if current_directory.rep_parent = null then 
                  
                  return parseRelative(Reste, current_directory);
               else
                  -- Cas normal : on monte au parent
                  return parseRelative(Reste, current_directory.rep_parent);
               end if;
            
            -- cas général
            else

               begin
                  Prochain := findChild(current_directory.L_enfant.all, Segment);
               exception
                  when FILE_NOT_EXIST =>
                     -- Si un morceau du chemin n'existe pas, on retourne null 
                     -- au lieu de faire planter tout le programme.
                     return null;
               end;

               if Prochain = null then
                  return null;
               elsif Reste /= "" and then not Prochain.isRepo then
                  raise VOID_INVALID_PATH with "Pas un répertoire.";
               else
                  return parseRelative(Reste, Prochain);
               end if;
         end if;
      end;

   end parseRelative;
   
   ----------
   
   function parsePath (fichier: in String; current_directory: in P_file) return P_file is

      firstSlash: Integer := 0;

   begin
   
      if fichier'Length = 0 then
         raise VOID_INVALID_PATH;
      else
         if fichier(fichier'First) = '/' then
            return(parseAbsolute(fichier, current_directory)); 
         elsif (fichier(fichier'First) = '.') or Is_Alphanumeric (fichier(fichier'First)) then
            return(parseRelative(fichier, current_directory));
         else
            raise VOID_INVALID_PATH;
         end if;
      end if;

   end parsePath;

   ----------

function extractParent (fichier : in String; current_directory : in P_file) return P_file is

   Last_Slash : Integer;

   begin

      if fichier = "/" then 
         return findRoot(current_directory); 
      end if;

      if fichier = "." or fichier = ".." then 
         return parsePath(fichier & "/..", current_directory); 
      end if;

      Last_Slash := Ada.Strings.Fixed.Index(fichier, "/", Ada.Strings.Backward);

      if Last_Slash = 0 then
         return current_directory;
      end if;
      if Last_Slash = fichier'Last then
         return extractParent(fichier(fichier'First .. Last_Slash - 1), current_directory);
      end if;

      declare
         Path_Part : constant String := fichier(fichier'First .. Last_Slash - 1);
         Target : constant String := (if Path_Part = "" then "/" else Path_Part);
      begin
         return parsePath(Target, current_directory);
      end;
   end extractParent;

   ----------

   function getExisting (fichier : in String; current_directory : in P_file) return Boolean is
   begin

      return parsePath(fichier, current_directory) /= null;
   
   exception

      when VOID_INVALID_PATH =>
         return False;

   end getExisting;

   ----------

   procedure putExisting (fichier: in String; current_directory: in P_file) is
   begin

      if getExisting (fichier, current_directory) then
         Put_Line(fichier & " existe bien.");
      else
         Put_Line (fichier & " n'existe pas.");

      end if;

   end putExisting;

   ----------

   function getExistingParent(fichier: in String; current_directory: in P_file) return Boolean is

      parent_node: P_file;
   
   begin

      parent_node:= extractParent(fichier, current_directory);
      if parent_node /= null then
         return True;
      else
         return False;
      end if;

   end getExistingParent; 

   ----------

   procedure testGetPathValidity(isValid: in Boolean) is
   begin

      if isValid = True then
         Put_Line("The path is correct");
      else
         Put_Line("The past isn't correct.");
         Put_Line("- and _ can't make a whole segment. Only alphanumerical values are allowed.");
      end if;
   
   end testGetPathValidity;

   ----------
   
   function getPathValidity (path : in String) return Boolean is
      
      function isValidChar(C : in Character) return Boolean is
      begin
         return (Is_Alphanumeric(C) or C = '.' or C = '_' or C = '-' or C = '/');
      end isValidChar;

      finish        : Integer;
      start         : Integer;
      segment_count : Integer := 0;

   begin
      if path'Length = 0 then
         return False;
      end if;

      for i in path'Range loop
         if not isValidChar(path(i)) then
            return False;
         end if;
         
         -- Interdiction de "//"
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
            
            if segment = "-" or segment = "_" then
               return False;
            end if;
            
         end; 

         start := finish + 1;
      end loop;

      return True;
   end getPathValidity;
   
   ----------

   procedure renameOrMove(source_file : in String; new_file: in String; current_directory: in P_file; memoire : in out Mem) is
   
      P_source: P_file;
      P_Dest_Parent : P_file;
      New_Name      : constant String := To_String(getName(new_file));


   begin
      P_source := parsePath(source_file, current_directory);
      P_Dest_Parent := extractParent(new_file, current_directory);
      if P_source = null or P_Dest_Parent = null then
         Put_Line("Erreur : Source ou dossier de destination introuvable.");
         return;
      end if;

      if extractParent(source_file, current_directory) = P_Dest_Parent then
         P_source.nom := To_Unbounded_String(New_Name);
      else
         copyRepoFile(source_file, new_file, current_directory,memoire);
         delete(source_file, current_directory, memoire);
      end if;

      pragma Assert (Invariant_SGF(findRoot(SGF.current_directory)), "Invariant rompu apres renameOrMove");
      
   end renameOrMove;

   ----------

   procedure menuRenameOrMove(current_directory: in P_file; memoire : in out Mem) is

      source_file: Unbounded_string;
      new_file: unbounded_string;

   begin

      Put_Line("This menu will guide you through moving a file or folder wherever you want");
      New_Line;

      loop
         Put_Line("Please enter the path of the name you wish to move:");
         source_file := To_Unbounded_String(Get_Line);
         exit when getPathValidity(To_String(source_file)) and then getExisting(To_string(source_file), current_directory);
         Put_Line("This file does not exist.");
      end loop;

   loop
      Put_Line("Please enter the desired new path:");
      new_file := To_Unbounded_String(Get_Line);

   declare
      Path_Dest : String := To_String(new_file);

      Parent_Ok : Boolean := extractParent(Path_Dest, current_directory) /= null;
      Exists    : Boolean := getExisting(Path_Dest, current_directory);

   begin

      exit when Parent_Ok and not Exists;
      
      if not Parent_Ok then
         Put_Line("Erreur : Le dossier de destination est introuvable.");
      else
         Put_Line("Erreur : Un fichier porte déjà ce nom à cet endroit.");
      end if;
      
   end;

      Put_Line("Invalid path: either the parent doesn't exist or the name is already taken.");
   end loop;

      copyRepoFile(To_string(source_file), To_string(new_file), current_directory, memoire);
      delete(To_string(source_file), current_directory, memoire);
   
   end menuRenameOrMove;

   ----------

   function isDirectory(path: in String; current_directory: in P_file) return Boolean is
   begin

      return parsePath(path, current_directory).isRepo;

   end isDirectory;

   ----------

   function getFileName(F : in P_file) return String is
   begin
      return To_String(F.nom);
   end getFileName;

   ----------

   function getFileSize(F : in P_file) return Integer is
   begin
      return F.taille;
   end getFileSize;

   
   ----------
   
   function getParent(F : in P_file) return P_file is
   begin
      return F.rep_parent;
   end getParent;

   ----------

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
   
   ----------

   function nvimSimulator return Integer is

      subtype Intervalle is Integer range 0 .. 10_000;
      package Aleatoire is new Ada.Numerics.Discrete_Random (Intervalle);
      use Aleatoire;
      Gen : Generator;
      nombre : Intervalle;

   begin
      
      Reset(Gen);
      nombre := Random(Gen);
      return nombre;

   end nvimSimulator;

   ----------

   procedure editFile(path : in String; current_dir : in P_file ; memoire : in out Mem) is
      target : P_file;
      added_size : Integer;
   begin
      target := parsePath(path, current_dir);

      if target = null then
         Put_Line("Erreur : Fichier introuvable.");
         return;
      elsif target.isRepo then
         Put_Line("Erreur : Impossible d'éditer un dossier avec nvim.");
         return;
      end if;

      added_size := nvimSimulator;
      changeSize(target, added_size);
      
      Put_Line("Édition terminée pour '" & To_String(target.nom) & "'.");
      Put_Line(" + " & Integer'Image(added_size) & " octets (Nouvelle taille : " & Integer'Image(target.taille) & " o)");

   end editFile;

   ---------- Preparation of SGF orders

   procedure changeDirectory(path : in String; current_directory : in out P_file) is

   pragma Assert (current_directory /= null, "cd: Repertoire actuel invalide");
   pragma Assert (path'Length > 0, "cd: Le chemin de destination est vide");

      destination : P_file;
   begin
      destination := parsePath(path, current_directory);

      if destination /= null and then destination.isRepo then
         current_directory := destination;
      else
         raise NOT_A_DIRECTORY;
      end if;
   end changeDirectory;

   ----------

   function getCurrentPath(pwd_file : in P_file) return Unbounded_String is
   
      parent_path : Unbounded_String;

   begin
      if pwd_file = null then
         raise VOID_POINTER_ERROR with "Error : file is null";
      end if;
      if pwd_file.Rep_Parent = null then
         return To_Unbounded_String("");
      else
         parent_path := getCurrentPath(pwd_file.Rep_Parent);
         return parent_path  & "/" & pwd_file.nom ;
      end if;
   end getCurrentPath;

   ----------

   procedure displayFileContent(path_or_name_to_display : in String) is
      to_display : P_file;
      list_ptr   : P_list;
   begin
      to_display := parsePath(path_or_name_to_display, SGF.current_directory);

      if to_display = null then
         Put_Line("Error: Path not found.");
         return;
      end if;

      if not to_display.isRepo then
         Put_Line("Content: " & To_String(to_display.nom));
         return;
      end if;

      list_ptr := getChildren(to_display);

      if list_ptr /= null and then not list_ptr.all.Is_Empty then
         for child of list_ptr.all loop
            Put_Line(To_String(child.nom));
         end loop;
      else
         Put_Line("(Empty directory)");
      end if;
   end displayFileContent;

   ----------

   procedure displayFileContentRecursive(path_or_name_to_display : in String; current_dir : P_file; indent : Natural := 0) is
      
      children_list_ancestor : P_list;
      to_display, current_parent : P_file;
      indent_str : String := (1 .. indent => ' '); 

   begin

      if path_or_name_to_display = "." or path_or_name_to_display = "" then
         to_display := current_dir;

      elsif containsSlash (path_or_name_to_display) then 
         current_parent := extractParent(path_or_name_to_display, current_dir);
         children_list_ancestor := getChildren(current_parent);
         to_display := findChild(children_list_ancestor.all, To_String(getName(path_or_name_to_display)));
      else
         current_parent := current_dir;
         children_list_ancestor := getChildren(current_dir);
         to_display := findChild(children_list_ancestor.all, path_or_name_to_display);
      end if;

      if to_display = null then
         return;
      end if;

      if not to_display.isRepo then 
         Put_Line(indent_str & "|-- [F] " & To_String(to_display.nom));
      
      elsif to_display.isRepo and then to_display.L_enfant.all.Is_Empty then 
         Put_Line(indent_str & "|-- [D] " & To_String(to_display.nom) & " (Vide)");

      else
         if path_or_name_to_display /= "." then
             Put_Line(indent_str & "|-- [D] " & To_String(to_display.nom));
         end if;
         
         for Child_File of getChildren(to_display).all loop
            
            displayFileContentRecursive(
               To_String(Child_File.nom), 
               to_display,    
               indent + 4
            );
         end loop;
      end if;

   end displayFileContentRecursive;

   ----------   

   procedure copy(to_be_copied : in P_file; new_parent : in P_file; memoire :in out Mem ) is

   pragma Assert (to_be_copied /= null, "copy: Source nulle");
   pragma Assert (new_parent /= null, "copy: Destination nulle");
   pragma Assert (new_parent.isRepo, "copy: La destination doit etre un dossier");

      current_temp : P_file := SGF.current_directory;
      temp: P_file;

   begin

      SGF.current_directory := new_parent;
      createFile (To_String(to_be_copied.nom), to_be_copied.isRepo, memoire);
      temp := new_parent.L_enfant.Last_Element;
      temp.droits_acces := sgf.current_user; --changesize to add
      temp.taille := to_be_copied.taille;
      SGF.current_directory := current_temp;

   end copy;

   ----------

   procedure Copy_Recursive(Src : P_file; Dest : P_file ; memoire : in out Mem) is
      New_Node : P_file;
   begin
      copy(Src, Dest, memoire);
      
      if Src.isRepo and then not Src.L_enfant.all.Is_Empty then
         
         New_Node := findChild(Dest.L_enfant.all, To_String(Src.nom));
         
         if New_Node /= null then
            for Child of Src.L_enfant.all loop
               Copy_Recursive(Child, New_Node, memoire);
            end loop;
         end if;
      end if;
   end Copy_Recursive;

   ----------

procedure copyRepoFile(copied_name_or_path : in String; path : in String; current_dir : P_file ; memoire : in out Mem ) is
   future_parent_dir  : P_file;
   to_be_copied       : P_file;
   Source_List        : P_list;
   New_Name           : constant String := To_string(getName(path)); 
begin
   future_parent_dir := extractParent(path, current_dir);
   
   if future_parent_dir = null then
       Put_Line("Erreur : Le dossier de destination est introuvable.");
       return;
   end if;
   
   if not future_parent_dir.isRepo then
       Put_Line("Erreur : La destination doit être un dossier.");
       return;
   end if;

   Source_List := Collect_Targets(copied_name_or_path, current_dir);

   if Source_List.Is_Empty then
      Put_Line("Erreur : Source introuvable (" & copied_name_or_path & ")");
      return;
   end if;

   for Element of Source_List.all loop
      to_be_copied := Element;
      
      if to_be_copied = future_parent_dir then
         Put_Line("Erreur : Impossible de copier le dossier dans lui-même.");
      else
         Copy_Recursive(to_be_copied, future_parent_dir, memoire);
         future_parent_dir.L_enfant.Last_Element.nom := To_Unbounded_String(New_Name);
      end if;
   end loop;
end copyRepoFile;

   ----------

   procedure changeSize(file : in P_file; new_data : in Integer) is

   parent : P_file := file.rep_parent;

   begin

      file.taille := file.taille + new_data;
      if file.rep_parent /= null then
         changeSize(file.rep_parent, new_data);
      end if;

   end changeSize;

   ---------- Menu procedures

   procedure menuCreate(current_directory: in P_file; memoire : in out Mem) is

      name: Unbounded_String;
      isDir: Character;

   begin

      loop
         Put_Line("Please enter the desired file path:");
         Flush;
         name := To_Unbounded_String(Get_Line);
         exit when getPathValidity(To_String(name)) and then getExistingParent(To_String(name), current_directory);
         Put_Line("Invalid path, please try again");
      end loop;

      loop
         Put_Line("Is it a directory? y/n");
         Get(isDir);
         Skip_Line;
         exit when isDir = 'y' or isDir = 'n';
         Put_Line("Please enter one of the specified characters");
      end loop;

      if isDir = 'y' then
         createFile(To_String(name), True, memoire);
      else 
         createFile(To_String(name), False, memoire);
      end if;

   end menuCreate;
      
   ----------

   procedure menuChangeDirectory(current_directory: in out P_file) is

      name: Unbounded_String;
      
   begin

      loop
         Put_Line("Please enter the directory you wish to move in:");
         name := To_Unbounded_String(Get_Line);
         exit when getExisting(To_String(name), current_directory) and isDirectory (To_String(name), current_directory);
         Put_Line("Invalid path, please try again");
      end loop;

      changeDirectory(To_String(name), current_directory);

   end menuChangeDirectory;

   ----------

   procedure menuRemoveFile(current_directory: in P_file; memoire :in out Mem) is

      name: Unbounded_String;
      isDir: Character;

   begin

      loop
         Put_Line("Is the file you wish to remove a directory? y/n");
         Get(isDir);
         Skip_Line;
         exit when isDir = 'y' or isDir = 'n';
         Put_Line("Please enter one of the specified characters");
      end loop;

      loop
         Put_Line("Please enter the file path of the file you wish to delete:");
         name := To_Unbounded_String(Get_Line);
         exit when getPathValidity(To_String(name)) and then getExisting(To_String(name), current_directory);
         Put_Line("Invalid path, please try again");
      end loop;

      if sgf.current_user = parsePath(To_string(name), current_directory).droits_acces then 
         if isDir = 'y' then
            deleteDirectory(To_String(name), current_directory, memoire);
         elsif isDir = 'n' then
            delete(To_String(name), current_directory,memoire);
         end if;
      else
         raise VOID_NOT_OWNER;
      end if;      

   end menuRemoveFile;

   ----------

   procedure menuDisplayFile(current_directory: in P_file) is

      choice: Character;
      path: Unbounded_String;
      isDir: Character;

   begin

      loop

         Put_Line("Do you wish to:");
         Put_Line("a. Display the content of a directory");
         Put_Line("b. Recursively display the content of a a directory");

         Get(choice);
         Skip_Line;

         exit when choice = 'a' or choice = 'b';
         Put_Line("Please enter either a or b");

      end loop;

      loop

         Put_Line("Please enter the name of the directory for which you wish to display the content:");

         path := To_Unbounded_String(Get_Line);

         exit when getPathValidity(To_string(path)) 
         and then getExisting(To_String(path), current_directory) 
         and then isDirectory (To_String(path), current_directory);
         Put_Line("Please enter a valid path");

      end loop;

      if choice = 'a' then
         displayFileContent(To_string(path));
      else
         displayFileContentRecursive(To_string(path), current_directory);
      end if;

   end menuDisplayFile;

   ---------- Terminal procedures and functions 



   procedure switchUser is
   begin

      Put_Line("Please the user you wish to log-in as:");
      sgf.current_user := To_Unbounded_String(Get_Line);

   end switchUser; 

   ----------

   procedure displayUser is
   begin

      Put_Line("You are currently logged-in as:");
      Put_Line(To_String(sgf.current_user));

   end displayUser;

   --------- 

   function isOwner(file: in P_file) return Boolean is
   begin

      if file.droits_acces = sgf.current_user then
         return True;
      else
         return False;
      end if;

   end isOwner;

   ---------

   procedure menuSwitchUser is
   begin

      Put_Line("You are currently logged in as " & To_String(sgf.current_user));
      switchUser;

   end menuSwitchUser;

   --------

   procedure menuDisplayOwner(current_directory: in P_file) is
   
      path: unbounded_string;

   begin

      Put_Line("Please enter the file for which you wish to see the owner:");
      path := To_Unbounded_String(Get_Line);
      if getExisting (To_string(path), current_directory) then
         displayOwner(To_String(path), current_directory);
      else
         Put_Line("This file does not exist.");
      end if;
      New_Line;

   end menuDisplayOwner;

   --------

   procedure menuEditFile(current_directory: in P_file; memoire : in out Mem) is
   
      path: unbounded_string;

   begin

      Put_Line("Please enter the file you wish to edit (nvim simulation):");
      path := To_Unbounded_String(Get_Line);
      
      if getExisting(To_String(path), current_directory) then
         editFile(To_String(path), current_directory, memoire);
      else
         Put_Line("This file does not exist.");
      end if;
      New_Line;

   end menuEditFile;

   --------

   procedure interactiveMenu(current_directory: in out P_file ; memoire : in out Mem) is

      choice: Integer;

   begin

      loop

      begin
         New_Line;
         Put_Line("---File Management System---");
         Put_Line("You are currently in " & To_String(getCurrentPath(current_directory)));
         Put_Line("1. Create a file (mkdir or touch)");
         Put_Line("2. Change directory (cd)");
         Put_Line("3. Delete a file (rm or rm -r)");
         Put_Line("4. Move or rename a file (mv)");
         Put_Line("5. Change the space taken by a file (non-directory)");
         Put_Line("6. Display the files in directory (ls)");
         Put_Line("7. Change the user (su)");
         Put_Line("8. Display the current user");
         Put_Line("9. Display the owner of a file");
         Put_Line("10. Leave");
         Put_Line("---Enter your choice---");

         Get(choice);
         Skip_Line;

      case choice is
         when 1 =>
            menuCreate(current_directory, memoire);
         when 2 => 
            menuChangeDirectory(current_directory);
         when 3 =>
            menuRemoveFile(current_directory, memoire);
         when 4 => 
            menuRenameOrMove(current_directory, memoire);
         when 5 =>
              menuEditFile(current_directory, memoire);
         when 6 =>
            menuDisplayFile(current_directory);
         when 7 =>
            switchUser;
         when 8 =>
            displayUser;
         when 9 =>
            menuDisplayOwner(current_directory);
         when 10 =>
            null;
         when others =>
            Put_Line("Invalid choice, try again");
      end case;

      exception
         when VOID_NOT_OWNER =>
            New_Line;
            Put_Line("You are not the owner of this file. You cannot delete it.");
            New_Line;
         when VOID_INVALID_PATH =>
            New_Line;
            Put_Line("This path is invalid. Try again.");
            New_Line;
         when VOID_ROOT_LOCATION =>
            New_Line;
            Put_Line("The user tried to access the root unaccordingly.");
            New_Line;
         when E : others =>
            Put_Line("Critical error: " & Ada.Exceptions.Exception_Name(E));
            Put_Line("Message:" & Ada.Exceptions.Exception_Message(E));
      end;

      exit when choice = 10;
      end loop;
      Put_Line("Good bye!");


   end interactiveMenu;

   --------

   procedure terminal(current_directory : in out P_file; memoire : in out Mem) is
   

   Input_Line : Unbounded_String;
   Command    : Unbounded_String;
   Arg1       : Unbounded_String;
   Arg2       : Unbounded_String;
   
   Racine_SGF : SGF.P_file; 
   Dossier_Courant : SGF.P_file;
   memoire_SGF : Mem;

   begin
      New_Line;
      Put_Line("               #########");
      Put_Line("              ##  ####  #"); 
      Put_Line("              ############");
      Put_Line("              ############");
      Put_Line("              ### ");
      Put_Line("              #########");
      Put_Line("  #          ####");
      Put_Line("  ###      ############");
      Put_Line("   ###    #########   #");
      Put_Line("    ###  #########");
      Put_Line("     ############");
      Put_Line("      ##########");
      Put_Line("        #     ##");
      Put_Line("        ##     #");
      Put_Line("               ##");
      New_Line;
      Put_Line("=============================================");
      Put_Line("    Welcome to the fedoRAPTOR terminal !");
      Put_Line("=============================================");
      New_Line;

      initMem(memoire_SGF);
      SGF.initRacine(Racine_SGF, memoire_SGF);
      New_Line;

      loop
      begin
         Put(To_String(SGF.getCurrentPath(SGF.getCurrentDirectory)) & " > ");
         
         Input_Line := To_Unbounded_String(Get_Line);

         declare
            Subs : Slice_Set;
         begin
            Command := To_Unbounded_String("");
            Arg1    := To_Unbounded_String("");
            Arg2    := To_Unbounded_String("");

            Create(S => Subs, From => To_String(Input_Line), Separators => " ", Mode => Multiple);

            if Slice_Count(Subs) >= 1 then Command := To_Unbounded_String(Slice(Subs, 1)); end if;
            if Slice_Count(Subs) >= 2 then Arg1 := To_Unbounded_String(Slice(Subs, 2)); end if;
            if Slice_Count(Subs) >= 3 then Arg2 := To_Unbounded_String(Slice(Subs, 3)); end if;
         end;


         if Command = "exit" then
            exit;

         elsif Command = "ls" then
            --ls -r
            if Arg1 = "-r" then
               if Arg2 /= "" then
                  
                  SGF.displayFileContentRecursive(To_String(Arg2), SGF.getCurrentDirectory);
               else
                  SGF.displayFileContentRecursive(".", SGF.getCurrentDirectory);
               end if;

            elsif Arg2 = "-r" then
               SGF.displayFileContentRecursive(To_String(Arg1), SGF.getCurrentDirectory);

            elsif Arg1 /= "" then
               SGF.displayFileContent(To_String(Arg1));

            --  "ls"
            else
               Dossier_Courant := SGF.getCurrentDirectory;
               if Dossier_Courant /= null and then Dossier_Courant.L_enfant /= null then
                  if Dossier_Courant.L_enfant.Is_Empty then
                     Put_Line("(Dossier vide)");
                  else
                     for Child of Dossier_Courant.L_enfant.all loop
                        Put_Line("  " & To_String(Child.nom));
                     end loop;
                  end if;
               end if;
            end if;

         elsif Command = "mkdir" then
            if Arg1 /= "" then 
               SGF.createFile(To_String(Arg1), True, memoire_SGF); 
            end if;

         elsif Command = "su" then
            if Arg1 /= "" then
               current_user := Arg1;
               Put_Line("Connecté en tant que : " & To_String(current_user));
            end if;
         elsif Command = "touch" then
            if Arg1 /= "" then 
               SGF.createFile(To_String(Arg1), False, memoire_SGF); 
            end if;

         elsif Command = "cd" then
            if Arg1 /= "" then 
               SGF.changeDirectory(To_String(Arg1), SGF.current_directory); 
            end if;

         elsif Command = "rm" then
            if To_String(Arg1) = "-r" then
               if Arg2 /= "" then
                  SGF.deleteDirectory(To_String(Arg2), SGF.getCurrentDirectory, memoire_SGF);
               else
                  Put_Line("Usage : rm -r <dossier>");
               end if;
            elsif Arg1 /= "" then 
               SGF.delete(To_String(Arg1), SGF.getCurrentDirectory, memoire_SGF);
            else
               Put_Line("Usage : rm <fichier> ou rm -r <dossier>");
            end if;

         elsif Command = "cp" then
            if Arg1 /= "" and Arg2 /= "" then
               SGF.copyRepoFile(To_String(Arg2), To_String(Arg1), SGF.getCurrentDirectory, memoire_SGF);
            else
               Put_Line("Usage : cp <source> <dest>");
            end if;
         
         elsif Command = "pwd" then
            Put_Line(To_String(SGF.getCurrentPath(SGF.getCurrentDirectory)));

         elsif Command = "nvim" then
               if Arg1 /= "" then
                  SGF.editFile(To_String(Arg1), SGF.getCurrentDirectory,memoire_SGF);
               else
                  Put_Line("Usage : nvim <fichier>");
               end if;
         
         elsif Command /= "" then
            Put_Line("Commande inconnue : " & To_String(Command));
         end if;

         exception
         when VOID_NOT_OWNER =>
            New_Line;
            Put_Line("You are not the owner of this file. Action denied.");
            New_Line;
         when VOID_INVALID_PATH =>
            New_Line;
            Put_Line("This path is invalid. Try again.");
            New_Line;
         when VOID_ROOT_LOCATION =>
            New_Line;
            Put_Line("The user tried to access the root unaccordingly.");
            New_Line;
         when E : others =>
            Put_Line("Critical error: " & Ada.Exceptions.Exception_Name(E));
            Put_Line("Message: " & Ada.Exceptions.Exception_Message(E));
      end;
   end loop;

   Put_Line("Leaving fedoRAPTOR terminal...");

end terminal;

   --------

end sgf;
