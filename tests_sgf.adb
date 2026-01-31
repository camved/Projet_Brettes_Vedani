with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with SGF; use SGF;
with Memoire; use Memoire;

procedure Tests_SGF is

   -- Variables globales pour le test
   Ma_Memoire     : Memoire.Mem;
   Ma_Racine      : SGF.P_file; 
   Enfant_Test    : SGF.P_file;
   Liste_Enfants  : SGF.P_list;
   Current_Dir    : SGF.P_file;

   procedure Assert(Condition : Boolean; Message : String) is
   begin
      if Condition then
         Put_Line("[OK]    " & Message);
      else
         Put_Line("[ECHEC] " & Message);
      end if;
   end Assert;

begin


   Put_Line("--- 1. Test Initialisation Racine ---");
   SGF.initRacine(Ma_Racine, Ma_Memoire);
   
   Assert(Ma_Racine /= null, "Racine bien allouee");
   Assert(SGF.getFileName(Ma_Racine) = "/", "Nom de la racine correct");
   Assert(SGF.getParent(Ma_Racine) = null, "Parent de la racine est null");
   Assert(SGF.isDirectory("/", Ma_Racine) = True, "La racine est un repertoire");
   New_Line;

   --------

   Put_Line("--- 2. Test Creation Fichier et Dossier ---");
   SGF.createFile("file1", False, Ma_Memoire); 
   SGF.createFile("Dossier1", True, Ma_Memoire);

   Liste_Enfants := SGF.getChildren(SGF.getCurrentDirectory);
   Assert(SGF.findChild(Liste_Enfants.all, "file1") /= null, "Fichier 'file1' cree");
   Assert(SGF.findChild(Liste_Enfants.all, "Dossier1") /= null, "Dossier 'Dossier1' cree");
   New_Line;

   --------

   Put_Line("--- 3. Test Suppression (rm) ---");
   SGF.createFile("a_supprimer", False, Ma_Memoire);
   Assert(SGF.getExisting("a_supprimer", SGF.getCurrentDirectory), "Fichier existe avant suppression");
   
   SGF.delete("a_supprimer", SGF.getCurrentDirectory, Ma_Memoire);
   Assert(not SGF.getExisting("a_supprimer", SGF.getCurrentDirectory), "Fichier bien supprime");
   New_Line;

   --------

   Put_Line("--- 5. Test Match_Pattern (Regex) ---");
   Assert(SGF.Match_Pattern("test.txt", "*.txt"), "Match *.txt fonctionne");
   Assert(not SGF.Match_Pattern("test.exe", "*.txt"), "Non-match fonctionne");
   
   SGF.createFile("script.sh", False, Ma_Memoire);
   declare
      Resultats : SGF.P_list := SGF.getRegexFiles("*.sh", SGF.getCurrentDirectory);
   begin
      Assert(not Resultats.Is_Empty, "getRegexFiles a trouve le fichier .sh");
   end;
   New_Line;

   --------

   Put_Line("--- 6. Test changeSize et Memoire ---");
   Enfant_Test := SGF.findChild(SGF.getChildren(SGF.getCurrentDirectory).all, "file1");
   if Enfant_Test /= null then
      declare
         Ancienne_Taille : Integer := SGF.getFileSize(Enfant_Test);
      begin
         SGF.changeSize(Enfant_Test, 50);
         Assert(SGF.getFileSize(Enfant_Test) = Ancienne_Taille + 50, "Taille du fichier augmentee");
      end;
   end if;
   New_Line;

   --------
   
   Put_Line("--- 7. Test CD et PWD ---");
   Current_Dir := SGF.getCurrentDirectory;
   SGF.changeDirectory("Dossier1", Current_Dir); 
   Assert(To_String(SGF.getCurrentPath(Current_Dir)) = "/Dossier1", "Chemin actuel correct");
   
   Put_Line("Tests termines.");

end Tests_SGF;