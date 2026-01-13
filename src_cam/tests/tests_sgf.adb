with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with SGF; use SGF; -- On importe ton paquet

procedure tests_sgf is

   Ma_Racine : SGF.File; 
   root_children : SGF.P_list;   
   Enfant_Trouve  : SGF.P_file;
   current : SGF.P_File;

begin

   Put("Test de initRacine");
   SGF.initRacine(Ma_Racine);
   
   if Ma_Racine.nom /= To_Unbounded_String("") then
      Put_Line("ÉCHEC : Le nom n'est pas correct.");
      Put_Line("Attendu : ");
      Put_Line("Obtenu  : " & To_String(Ma_Racine.nom));
      
   elsif Ma_Racine.taille /= 1 then
      Put_Line("ÉCHEC : La taille n'est pas correcte.");
      
   elsif Ma_Racine.rep_parent /= null then
      Put_Line("ÉCHEC : Le parent devrait être null.");
      
   elsif Ma_Racine.isRepo /= True then
      Put_Line("ÉCHEC : isRepo devrait être True.");   
   else
      Put_Line("OK !"); 
   end if;

  ---------------------------------------------------------
   Put_Line("--- Test create file ---");
   Put_Line("création de test et trucs, enfants de root");

   SGF.createFile("test", False);
   SGF.createFile("trucs", False);

   Put_Line("--- Test trouver liste ---");
   root_children := SGF.getChildren(SGF.getCurrentDirectory);

   Put_Line("--- Test récupérer enfant ---");

   Enfant_Trouve := SGF.findChild(root_children.all, "test");

   if Enfant_Trouve /= null then
      Put_Line("SUCCES : Enfant 'test' trouvé !");
   else
      Put_Line("ECHEC : Enfant introuvable.");
   end if;

   Put_Line ("Test pwd sans le chemin");
   
   current := SGF.getCurrentDirectory;

   Put(To_String(SGF.getCurrentPath(current)));
   Put_Line("SUCCES : chemin trouvé !");

   --  SGF.change_directory("Raptor");
   --  SGF.createFile ("Raptor_file", False);
   --  SGF.change_directory("Raptor_file");
   SGF.createFile ("Raptor_directory", True);
   SGF.changeDirectory("Raptor_directory");
   
   Put_Line ("Test pwd sans le chemin");
   current := SGF.getCurrentDirectory;
   Put(To_String(SGF.getCurrentPath(current)));
   SGF.createFile("raptor_baby",True);
   SGF.createFile("ankilosaure", False);
   --  SGF.changeDirectory("raptor_baby");
   Put_Line ("test_raptor_dir");
   current := SGF.getCurrentDirectory;
   SGF.changeDirectory("raptor_baby");
   current := SGF.getCurrentDirectory;
   Put_Line("couille dans le potage");


   

   SGF.copy_file ("/Raptor_directory/raptor_baby/", "ankilosaure", current);

   SGF.deleteFile("./raptor_baby/ankilosaure", current);
  



end tests_sgf; 