with Ada.Text_IO; use Ada.Text_IO;
with SGF;         use SGF;
with memoire;     use memoire;

procedure Main is
   
   Racine_SGF      : SGF.file;
   Dossier_Courant : SGF.P_file;
   Memoire_SGF     : Mem;
   Choix           : Character;

begin
   -- Initialisation unique au début
   initMem(Memoire_SGF);
   SGF.initRacine(Racine_SGF, Memoire_SGF);
   
   -- Le dossier courant démarre à la racine (ou utilisez SGF.current_directory si global)
   Dossier_Courant := SGF.getCurrentDirectory;

   loop
      New_Line;
      Put_Line("1. Terminal (fedoRAPTOR)");
      Put_Line("2. Menu Interactif Classique");
      Put_Line("3. Quitter");
      Put("Choix > ");
      Get(Choix);
      Skip_Line;

      case Choix is
         when '1' => 
            -- APPEL DE VOTRE NOUVELLE FONCTION
            SGF.Terminal(Dossier_Courant, Memoire_SGF);
            
         when '2' =>
            SGF.switchUser;
            SGF.interactiveMenu(Dossier_Courant, Memoire_SGF);
            
         when '3' => 
            exit;
            
         when others => 
            Put_Line("Choix invalide.");
      end case;
   end loop;

end Main;