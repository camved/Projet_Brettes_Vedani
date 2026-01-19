with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with SGF; use SGF;

procedure Tests_SGF is

   -- Variables globales pour le test
   Ma_Racine      : SGF.File; 
   Enfant_Test    : SGF.P_file;
   Dossier_Source : SGF.P_file;
   Dossier_Dest   : SGF.P_file;
   Fichier_Copie  : SGF.P_file;
   Liste_Enfants  : SGF.P_list;
   Current_Dir : SGF.P_file;

   -- Une petite procédure utilitaire pour rendre les tests lisibles
   -- Si Condition est Vrai -> Affiche OK
   -- Si Condition est Faux -> Affiche ECHEC
   procedure Assert(Condition : Boolean; Message : String) is
   begin
      if Condition then
         Put_Line("[OK]    " & Message);
      else
         Put_Line("[ECHEC] " & Message);
      end if;
   end Assert;

begin

   ---------------------------------------------------------
   -- 1. Test de l'initialisation (La Racine)
   ---------------------------------------------------------
   Put_Line("--- 1. Test Initialisation Racine ---");
   
   SGF.initRacine(Ma_Racine);
   
   -- On teste chaque propriété
   Assert(Ma_Racine.nom = To_Unbounded_String(""), "Nom de la racine vide");
   Assert(Ma_Racine.taille = 1,                    "Taille initiale a 1");
   Assert(Ma_Racine.rep_parent = null,             "Parent est null");
   Assert(Ma_Racine.isRepo = True,                 "Est un repertoire (isRepo = True)");

   New_Line;

   ---------------------------------------------------------
   -- 2. Test de création de Fichier (Simple)
   ---------------------------------------------------------
   Put_Line("--- 2. Test Creation Fichier Simple ---");

   SGF.createFile("file1", False); -- Création d'un fichier standard
   
   -- Vérification
   Liste_Enfants := SGF.getChildren(SGF.getCurrentDirectory);
   Enfant_Test   := SGF.findChild(Liste_Enfants.all, "file1");

   if Enfant_Test /= null then
      Assert(True, "Fichier 'file1' trouve dans le dossier courant");
      Assert(Enfant_Test.isRepo = False, "'file1' n'est pas un dossier");
      Assert(Enfant_Test.nom = To_Unbounded_String("file1"), "Nom du fichier correct");
   else
      Assert(False, "Fichier 'file1' introuvable apres creation !");
   end if;

   New_Line;

   ---------------------------------------------------------
   -- 3. Test de création de Dossier et Navigation
   ---------------------------------------------------------
   Put_Line("--- 3. Test Creation Dossier et Navigation ---");

   SGF.createFile("Dossier_Raptor", True); -- isRepo = True
   
   -- Vérification existence
   Liste_Enfants := SGF.getChildren(SGF.getCurrentDirectory);
   Enfant_Test   := SGF.findChild(Liste_Enfants.all, "Dossier_Raptor");
   
   Assert(Enfant_Test /= null, "Creation du dossier 'Dossier_Raptor' reussie");
   
   if Enfant_Test /= null then
       Assert(Enfant_Test.isRepo, "'Dossier_Raptor' est bien marque comme dossier");
   end if;

   -- Test changement de répertoire (cd)
   SGF.changeDirectory("Dossier_Raptor");
   Current_Dir := SGF.getCurrentDirectory;
   
   Assert(To_String(Current_Dir.nom) = "Dossier_Raptor", "Changement de repertoire effectif (Current = Raptor)");

   New_Line;

   ---------------------------------------------------------
   -- 4. Test du Chemin Absolu (pwd)
   ---------------------------------------------------------
   Put_Line("--- 4. Test du Chemin (PWD) ---");

   -- On est actuellement dans /Dossier_Raptor
   -- Créons un sous-dossier pour tester la profondeur
   SGF.createFile("Bebe_Raptor", True);
   SGF.changeDirectory("Bebe_Raptor");
   
   -- Chemin attendu : /Dossier_Raptor/Bebe_Raptor
   declare
      Chemin_Actuel : String := To_String(SGF.getCurrentPath(SGF.getCurrentDirectory));
      Chemin_Attendu : String := "/Dossier_Raptor/Bebe_Raptor";
   begin
      -- Note: Selon ton implémentation, le premier slash peut varier, adapte le test si besoin
      if Chemin_Actuel = Chemin_Attendu then
         Assert(True, "Chemin complet correct : " & Chemin_Actuel);
      else
         Assert(False, "Erreur chemin. Attendu: " & Chemin_Attendu & " | Obtenu: " & Chemin_Actuel);
      end if;
   end;

   ---------------------------------------------------------
   -- 5. Test de changeSize (Mise à jour récursive de la taille)
   ---------------------------------------------------------
   Put_Line("--- 5. Test de changeSize (Recursif) ---");

   -- On crée un fichier pour le test
   SGF.createFile("fichier_lourd", False);
   
   -- On récupère le pointeur vers ce fichier
   Liste_Enfants := SGF.getChildren(SGF.getCurrentDirectory);
   Enfant_Test   := SGF.findChild(Liste_Enfants.all, "fichier_lourd");

   if Enfant_Test /= null then
      -- Taille initiale doit être 1 (valeur par défaut)
      -- On simule l'ajout de 100 octets de données
      SGF.changeSize(Enfant_Test, 100);

      -- Vérification 1 : Le fichier a grossi
      Assert(Enfant_Test.taille = 101, "Taille du fichier mise a jour (1 + 100 = 101)");

      -- Vérification 2 : La racine (parent) a grossi aussi !
      -- La racine avait 1 (elle-même) + 1 (fichier_lourd initial) = 2.
      -- Elle devrait maintenant avoir 2 + 100 = 102.
      -- (Note : Cela dépend si ton createfile ajoute déjà la taille au parent, 
      --  adapte la valeur 102 selon ta logique d'init, mais le principe est là).
      Put_Line("Taille Racine actuelle : " & Integer'Image(SGF.current_directory.taille));
      Assert(SGF.current_directory.taille > 100, "La taille est remontee au parent (Racine)");
   else
      Assert(False, "Impossible de tester changeSize (fichier non cree)");
   end if;

   New_Line;

   ---------------------------------------------------------
   -- 6. Test de l'Affichage (Vérification Visuelle)
   ---------------------------------------------------------
   Put_Line("--- 6. Test Affichage (Regardez la console) ---");
   
   -- Créons une structure un peu complexe pour voir l'arbre
   SGF.createFile("Dossier_A", True);
   SGF.changeDirectory("Dossier_A");
   SGF.createFile("photo.jpg", False);
   SGF.createFile("Sous_Dossier_B", True);
   SGF.changeDirectory("Sous_Dossier_B");
   SGF.createFile("texte.txt", False);
   
   -- Retour à la racine pour afficher tout l'arbre
   SGF.displayFile(SGF.current_directory);
   SGF.changeDirectory(".."); -- Remonte dans A
   SGF.changeDirectory(".."); -- Remonte à la racine
   SGF.changeDirectory("..");-- Remonte à la racine
    -- Remonte à la racine
   SGF.displayFile(SGF.current_directory);

   Put_Line(">>> Affichage Recursif (Tree) :");
   -- Appel de TA fonction displayFileContentRecursive
   -- On affiche à partir de la racine actuelle, indentation 0
   SGF.displayFileContentRecursive(".", SGF.getCurrentDirectory, 0);

   New_Line;
   Put_Line(">>> Affichage Simple du contenu de Dossier_A :");
   SGF.displayFileContent("Bebe_Raptor/Dossier_A");


   New_Line;

   ---------------------------------------------------------
   -- 7. Test de la Copie Récursive (copyRepoFile)
   ---------------------------------------------------------
   Put_Line("--- 7. Test de copyRepoFile ---");

   -- Préparation : 
   -- On a déjà "Dossier_A" (qui contient photo.jpg et Sous_Dossier_B/texte.txt)
   -- On crée un dossier "Backup" vide à la racine
   SGF.createFile("Backup", True);

   -- Action : Copier "Dossier_A" DANS "Backup"
   -- Param 1 (path destination) : "Backup"
   -- Param 2 (source) : "Dossier_A"
   -- Param 3 (contexte) : racine
   Put_Line("Tentative de copie de Dossier_A vers Backup...");
   SGF.copyRepoFile("Backup", "Bebe_Raptor/Dossier_A", SGF.getCurrentDirectory);

   -- Vérification
   -- On va voir dans Backup si Dossier_A existe
   SGF.changeDirectory("Backup"); -- On entre dans Backup
   
   Liste_Enfants := SGF.getChildren(SGF.getCurrentDirectory);
   Fichier_Copie := SGF.findChild(Liste_Enfants.all, "Dossier_A");

   if Fichier_Copie /= null then
      Assert(True, "Dossier_A existe bien dans Backup");
      
      -- Vérifions si les enfants ont suivi (récursivité)
      -- On descend dans le Dossier_A copié
      SGF.changeDirectory("Dossier_A"); 
      
      Liste_Enfants := SGF.getChildren(SGF.getCurrentDirectory);
      
      if SGF.findChild(Liste_Enfants.all, "photo.jpg") /= null then
         Assert(True, "Le fichier 'photo.jpg' a bien ete copie");
      else
         Assert(False, "ECHEC: 'photo.jpg' manquant dans la copie");
      end if;

      if SGF.findChild(Liste_Enfants.all, "Sous_Dossier_B") /= null then
         Assert(True, "Le sous-dossier 'Sous_Dossier_B' a bien ete copie");
      else
         Assert(False, "ECHEC: 'Sous_Dossier_B' manquant dans la copie");
      end if;

   else
      Assert(False, "ECHEC CRITIQUE : Dossier_A n'a pas ete cree dans Backup");
   end if;



end Tests_SGF;