with sgf;

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
            -- On pourrait stocker le pattern ici si besoin
            return Resultat;
         end if;
      end loop;
      return Resultat;
   end containsRegex;

   ----------

   -- On garde uniquement Match_Pattern (la version propre et commentée)
   function Match_Pattern(FileName : String; Pattern : String) return Boolean is
   begin
      -- CAS DE BASE : Fin du motif
      if Pattern'Length = 0 then
         return FileName'Length = 0;
      end if;

      -- CAS 1 : Le motif commence par '*'
      if Pattern(Pattern'First) = '*' then
         -- Si '*' est le dernier char du motif, il matche tout
         if Pattern'Length = 1 then
            return True;
         end if;
         
         -- Récursion : soit on consomme le *, soit on consomme un caractère du nom
         if Match_Pattern(FileName, Pattern(Pattern'First + 1 .. Pattern'Last)) then
            return True;
         elsif FileName'Length > 0 then
             return Match_Pattern(FileName(FileName'First + 1 .. FileName'Last), Pattern);
         else
             return False;
         end if;

      -- CAS 2 : Le motif commence par '?'
      elsif Pattern(Pattern'First) = '?' then
         if FileName'Length = 0 then
            return False;
         else
            return Match_Pattern(FileName(FileName'First + 1 .. FileName'Last), 
                                 Pattern(Pattern'First + 1 .. Pattern'Last));
         end if;

      -- CAS 3 : Caractère standard
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

   -- Correction du nom, ajout du return type, et utilisation de Match_Pattern
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
      -- 1. Cas "ls" vide ou "." -> le dossier courant
      if Name_Or_Path = "" or Name_Or_Path = "." then
         Target_List.Append(Current_Dir);
         return Target_List;
      end if;

      -- 2. On sépare le chemin (Où chercher ?) du nom/motif (Quoi chercher ?)
      if containsSlash(Name_Or_Path) then
         Parent_Dir   := extractParent(Name_Or_Path, Current_Dir);
         Pattern_Name := getName(Name_Or_Path);
      else
         Parent_Dir   := Current_Dir;
         Pattern_Name := To_Unbounded_String(Name_Or_Path);
      end if;

      if Parent_Dir = null then return Target_List; end if;

      -- 3. C'est ici qu'on décide : Regex ou Nom Exact ?
      if containsRegex(To_String(Pattern_Name)).Existe then
         -- C'est une Regex (*.txt) -> On récupère tout ce qui matche
         return getRegexFiles(To_String(Pattern_Name), Parent_Dir);
      else
         -- C'est un nom simple -> On cherche juste ce fichier
         Simple_Target := findChild(Parent_Dir.L_enfant.all, To_String(Pattern_Name));
         if Simple_Target /= null then
            Target_List.Append(Simple_Target);
         end if;
         return Target_List;
      end if;
   exception
      when others => return Target_List; -- En cas d'erreur, liste vide
   end Collect_Targets;

   ---------- Root Initialization

   procedure initRacine (root: in out file) is
      pointer_root : P_file;
   begin
      pointer_root := new file;
      pointer_root.nom := To_Unbounded_String("");
      pointer_root.droits_acces := sgf.current_user;
      pointer_root.taille := 1; --Volume total divisé par 10Ko pour qu'on ne manie qu'une unité simple
      pointer_root.rep_parent := null;
      pointer_root.L_enfant := new File_List_Pkg.List;
      pointer_root.isRepo := True;

      root := pointer_root.all;
      current_directory := pointer_root;
      
   end initRacine;

   ---------- Files and directories initialization/destruction
      
   procedure createFile (nom_or_path: in String; isRepo : in Boolean) is
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
         pointer_created.taille := 1;
         pointer_created.rep_parent := Target_Parent; 
         pointer_created.isRepo := isRepo;

         changeSize (Target_Parent, 1);

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


   end createFile;

   ----------

   procedure delete (name_or_path: in String ; current_dir : P_file) is
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
             
             if Has_Element(C) then
                Target_Parent.L_enfant.all.Delete(C);
                Free(pointer_deleted); 
             end if;
         end if;
      end loop;

   end delete;

   ----------

   procedure deleteDirectory (name_or_path: in String ; current_dir : P_file) is
      -- On garde tes noms de variables
      target_parent : P_file;
      deleted_to_be : P_file;
      child_cursor : File_List_Pkg.Cursor;
      child_ptr : P_file;
      
      -- Variable nécessaire pour le Regex
      Targets : P_list;
      use File_List_Pkg; 

   begin
      -- 1. Récupération des dossiers cibles
      Targets := Collect_Targets(name_or_path, current_dir);

      if Targets.Is_Empty then
         Put_Line("Erreur : Aucun dossier trouvé pour '" & name_or_path & "'");
         return;
      end if;

      -- 2. Boucle sur les dossiers trouvés
      for Element of Targets.all loop
         
         -- On assigne l'élément courant à TA variable historique
         deleted_to_be := Element;

         if not deleted_to_be.isRepo then
            Put_Line("Erreur : '" & To_String(deleted_to_be.nom) & "' n'est pas un dossier.");
         
         elsif deleted_to_be.rep_parent = null then
            Put_Line("Impossible de supprimer la racine.");

         else
            -- 3. VIDAGE RÉCURSIF (inchangé, sauf qu'on utilise ta boucle while)
            while not deleted_to_be.L_enfant.all.Is_Empty loop
               
               child_ptr := deleted_to_be.L_enfant.all.First_Element;
               
               if child_ptr.isRepo then
                  -- Appel récursif
                  deleteDirectory(To_String(child_ptr.nom), deleted_to_be); 
               else
                  -- Appel delete fichier
                  delete(To_String(child_ptr.nom), deleted_to_be);
               end if;
            end loop;

            -- 4. SUPPRESSION DU DOSSIER LUI-MÊME
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

   procedure displayFile(current_directory : in P_file) is
      use Ada.Containers; -- Pour Count_Type
   begin
      
      -- 1. Sécurité
      if current_directory = null then
         Put_Line("Erreur : Le fichier à afficher est null.");
         return;
      end if;

      New_Line;

      -- 2. Métadonnées
      Put("Type             : ");
      if current_directory.isRepo then
         Put_Line("d (Dossier)"); 
      else
         Put_Line("- (Fichier)"); 
      end if;

      Put_Line("Access Right     : " & To_String(current_directory.droits_acces));
      Put_Line("Size             : " & Integer'Image(current_directory.taille) & " o");
      Put_Line("File name        : " & To_String(current_directory.nom));

      -- 3. Compteur
      Put("Sous répertoires : ");
      if current_directory.isRepo and then current_directory.L_enfant /= null then
         Put_Line(Count_Type'Image(current_directory.L_enfant.Length));
      else
         Put_Line("0 (Non applicable)");
      end if;

      -- 4. Parent
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

      -- 5. Liste des enfants
      if current_directory.isRepo then
         
         if current_directory.L_enfant = null or else current_directory.L_enfant.Is_Empty then
            Put_Line("   (Dossier vide)");
         else
            Put_Line("   Contenu de " & (if To_String(current_directory.nom) = "" then "root" else To_String(current_directory.nom)) & " :");
            
            -- La boucle "for ... of" déréférence automatiquement les éléments de la liste
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
   
   ----------
   
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

   ----------

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

   ----------

   function getExisting (fichier : in String; current_directory : in P_file) return Boolean is
   begin

      return parsePath(fichier, current_directory) /= null;
   
   exception

      when VOID_INVALID_PATH | EMPTY_STRING | INVALID_FIRST_CHAR =>
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
   
   ----------

   procedure renameOrMove(source_file : in String; new_file: in String; current_directory: in P_file) is
   
      P_source: P_file;
      P_new: P_file;

   begin

      P_source := parsePath(source_file, current_directory);
      P_new := parsePath(new_file, current_directory);

      if extractParent(source_file, current_directory) = extractParent(new_file, current_directory) then
         P_source.nom := getName(source_file);
      else
         copyRepoFile (source_file, new_file, current_directory);
         delete (source_file, current_directory);
      end if;

   end renameOrMove;

   ----------

   procedure menuRenameOrMove(current_directory: in P_file) is

      source_file: Unbounded_string;
      new_file: unbounded_string;

   begin

      Put_Line("This menu will guide you through copying a file or folder wherever you want");

      loop
         Put_Line("Please enter the path of the name you wish to copy:");
         source_file := To_Unbounded_String(Get_Line);
         exit when getPathValidity(To_String(source_file)) and then getExisting(To_string(source_file), current_directory);
         raise VOID_INVALID_PATH;
      end loop;

      loop
         Put_Line("Please enter the desired path:");
         new_file := To_Unbounded_String(Get_Line);
         exit when getPathValidity(To_String(new_file))
            and then getExisting(To_String(getCurrentPath(extractParent((To_String(new_file)), current_directory))), current_directory);
         raise VOID_INVALID_PATH;
      end loop;

      copyRepoFile(To_string(source_file), To_string(new_file), current_directory);
      delete(To_string(source_file), current_directory);
   
   end menuRenameOrMove;

   ----------

   function isDirectory(path: in String; current_directory: in P_file) return Boolean is
   begin

      return parsePath(path, current_directory).isRepo;

   end isDirectory;

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

   function plumaSimulator return Integer is

      subtype Intervalle is Integer range 0 .. 10_000;
      package Aleatoire is new Ada.Numerics.Discrete_Random (Intervalle);
      use Aleatoire;
      Gen : Generator;
      nombre : Intervalle;

   begin
      
      Reset(Gen);
      nombre := Random(Gen);
      return nombre;

   end plumaSimulator;

   ---------- Preparation of SGF orders

   procedure changeDirectory(path : in String) is
         parent_destination : P_file;
         destination : P_file;

   begin

      if path = ".." then
         if SGF.current_directory.rep_parent /= null then
            SGF.current_directory := SGF.current_directory.rep_parent;
         else
            Put_Line("Vous etes deja a la racine.");
         end if;
         return; -- On s'arrête là, le travail est fait
      end if;
   
      if containsSlash(path) then
         parent_destination := SGF.extractParent(path,SGF.current_directory);
         destination := sgf.findChild(parent_destination.L_enfant.all, To_String(getName(path)));
      else
         destination := sgf.findChild(SGF.current_directory.L_enfant.all, To_String(getName(path)));
      end if;

      if Destination = null then
         return;
      end if;

      if not Destination.isRepo then
         return;
      end if;

      SGF.current_directory := Destination;
         

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

      children_list : P_list;
      children_list_to_display : P_list;
      to_display, current_parent : P_file;

   begin

      if containsSlash (path_or_name_to_display) then 
         current_parent := extractParent(path_or_name_to_display, SGF.current_directory);
         children_list := getChildren(current_parent);
         to_display := findChild(children_list.all, To_String(getName(path_or_name_to_display)));
      else
         current_parent := SGF.current_directory;
         children_list := getChildren(SGF.current_directory);
         to_display := findChild(children_list.all, path_or_name_to_display);
      end if;

      children_list_to_display := getChildren(to_display);

      for child of children_list_to_display.all loop
         Put_Line(To_String(child.nom));
      end loop;

   end displayFileContent;

   ----------

   procedure displayFileContentRecursive(path_or_name_to_display : in String; current_dir : P_file; indent : Natural := 0) is
      
      children_list_ancestor : P_list;
      to_display, current_parent : P_file;
      indent_str : String := (1 .. indent => ' '); 

   begin

      -- 1. CAS SPECIAL : Si le chemin est "." ou vide, c'est le dossier courant lui-même
      if path_or_name_to_display = "." or path_or_name_to_display = "" then
         to_display := current_dir;

      -- 2. SINON : On cherche le fichier/dossier demandé
      elsif containsSlash (path_or_name_to_display) then 
         current_parent := extractParent(path_or_name_to_display, current_dir);
         children_list_ancestor := getChildren(current_parent);
         to_display := findChild(children_list_ancestor.all, To_String(getName(path_or_name_to_display)));
      else
         current_parent := current_dir;
         children_list_ancestor := getChildren(current_dir);
         to_display := findChild(children_list_ancestor.all, path_or_name_to_display);
      end if;

      -- 3. SECURITE : Si introuvable, on sort
      if to_display = null then
         return;
      end if;

      -- 4. AFFICHAGE ET RECURSION
      if not to_display.isRepo then 
         -- C'est un fichier
         Put_Line(indent_str & "|-- [F] " & To_String(to_display.nom));
      
      elsif to_display.isRepo and then to_display.L_enfant.all.Is_Empty then 
         -- C'est un dossier vide
         Put_Line(indent_str & "|-- [D] " & To_String(to_display.nom) & " (Vide)");

      else
         -- C'est un dossier avec du contenu
         -- On n'affiche le nom que si ce n'est pas le point de départ "." (pour éviter une ligne moche au début)
         if path_or_name_to_display /= "." then
             Put_Line(indent_str & "|-- [D] " & To_String(to_display.nom));
         end if;
         
         for Child_File of getChildren(to_display).all loop
            
            -- ASTUCE : Pour la récursion, on change le contexte.
            -- Le "current_dir" devient le dossier qu'on est en train de visiter (to_display)
            -- Et on demande d'afficher l'enfant par son nom simple.
            displayFileContentRecursive(
               To_String(Child_File.nom), 
               to_display,    -- Le dossier actuel devient la référence pour l'enfant
               indent + 4
            );
         end loop;
      end if;

   end displayFileContentRecursive;

   ----------   

   procedure copy(to_be_copied : in P_file; new_parent : in P_file) is

      current_temp : P_file := SGF.current_directory;

   begin
      SGF.current_directory := new_parent;
      createFile (To_String(to_be_copied.nom), to_be_copied.isRepo);
      SGF.current_directory := current_temp;

   end copy;

   ----------

   procedure Copy_Recursive(Src : P_file; Dest : P_file) is
      New_Node : P_file;
   begin
      -- Copie du fichier/dossier lui-même
      copy(Src, Dest);
      
      -- Si c'est un dossier non vide, on copie les enfants
      if Src.isRepo and then not Src.L_enfant.all.Is_Empty then
         
         -- On retrouve le nouveau dossier créé dans la destination
         New_Node := findChild(Dest.L_enfant.all, To_String(Src.nom));
         
         if New_Node /= null then
            for Child of Src.L_enfant.all loop
               Copy_Recursive(Child, New_Node);
            end loop;
         end if;
      end if;
   end Copy_Recursive;

   ----------

   procedure copyRepoFile(path : in String; copied_name_or_path : in String; current_dir : P_file ) is

         future_parent_dir  : P_file;
         to_be_copied       : P_file;
         children_list_temp : P_list; 
         Dest_List : P_list;

   begin

      Dest_List := Collect_Targets(path, current_dir);
      
      if Dest_List.Is_Empty then
          Put_Line("Erreur : Destination introuvable (" & path & ")");
          return;
      end if;
      
      future_parent_dir := Dest_List.First_Element;
      
      if not future_parent_dir.isRepo then
          Put_Line("Erreur : La destination '" & To_String(future_parent_dir.nom) & "' doit être un dossier.");
          return;
      end if;

      children_list_temp := Collect_Targets(copied_name_or_path, current_dir);

      if children_list_temp.Is_Empty then
         Put_Line("Erreur : Source introuvable (" & copied_name_or_path & ")");
         return;
      end if;
      for Element of children_list_temp.all loop
         
         to_be_copied := Element;
         if to_be_copied = future_parent_dir then
            Put_Line("Erreur : Impossible de copier le dossier dans lui-même.");
         else
            Copy_Recursive(to_be_copied, future_parent_dir);
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

   procedure menuCreate(current_directory: in P_file) is

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
         createFile(To_String(name), True);
      else 
         createFile(To_String(name), False);
      end if;

   end menuCreate;
      
   ----------

   procedure menuChangeDirectory(current_directory: in P_file) is

      name: Unbounded_String;
      
   begin

      loop
         Put_Line("Please enter the directory you want to move in:");
         name := To_Unbounded_String(Get_Line);
         exit when getExisting(To_String(name), current_directory) and isDirectory (To_String(name), current_directory);
         Put_Line("Invalid path, please try again");
      end loop;

      changeDirectory (To_String(name));

   end menuChangeDirectory;

   ----------

   procedure menuRemoveFile(current_directory: in P_file) is

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

      if isDir = 'y' then
         deleteDirectory(To_String(name), current_directory);
      elsif isDir = 'n' then
         delete(To_String(name), current_directory);
      end if;

   end menuRemoveFile;

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

end sgf;