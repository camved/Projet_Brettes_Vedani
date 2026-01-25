with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with SGF;                   use SGF;
with GNAT.String_Split;     use GNAT.String_Split;
with Ada.Containers;        use Ada.Containers; -- Nécessaire pour afficher la taille des listes

procedure terminal is

   Input_Line : Unbounded_String;
   Command    : Unbounded_String;
   Arg1       : Unbounded_String;
   Arg2       : Unbounded_String;
   
   Racine_SGF : SGF.file; 
   Dossier_Courant : SGF.P_file; 

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

   
   -- 1. Initialisation du Système
   SGF.initRacine(Racine_SGF);
   New_Line;

   loop
      -- 2. Affichage du Prompt
      Put(To_String(SGF.getCurrentPath(SGF.getCurrentDirectory)) & " > ");
      
      -- 3. Lecture de la commande
      Input_Line := To_Unbounded_String(Get_Line);

      -- 4. Parsing (Découpage)
      declare
         Subs : Slice_Set;
      begin
         -- Réinitialisation des variables
         Command := To_Unbounded_String("");
         Arg1    := To_Unbounded_String("");
         Arg2    := To_Unbounded_String("");

         Create(S => Subs, From => To_String(Input_Line), Separators => " ", Mode => Multiple);

         if Slice_Count(Subs) >= 1 then Command := To_Unbounded_String(Slice(Subs, 1)); end if;
         if Slice_Count(Subs) >= 2 then Arg1 := To_Unbounded_String(Slice(Subs, 2)); end if;
         if Slice_Count(Subs) >= 3 then Arg2 := To_Unbounded_String(Slice(Subs, 3)); end if;
      end;

      -- 5. Exécution des commandes

      if Command = "exit" then
         exit;

      elsif Command = "ls" then
         
         -- CAS 1 : "ls -r ..." (L'option est en premier)
         if Arg1 = "-r" then
            if Arg2 /= "" then
               -- ls -r dossier
               SGF.displayFileContentRecursive(To_String(Arg2), SGF.getCurrentDirectory);
            else
               -- ls -r (sur le courant)
               SGF.displayFileContentRecursive(".", SGF.getCurrentDirectory);
            end if;

         -- CAS 2 : "ls dossier -r" (L'option est en deuxième)
         elsif Arg2 = "-r" then
            SGF.displayFileContentRecursive(To_String(Arg1), SGF.getCurrentDirectory);

         -- CAS 3 : "ls dossier" (Pas de -r, mais un chemin spécifié)
         elsif Arg1 /= "" then
            SGF.displayFileContent(To_String(Arg1));

         -- CAS 4 : "ls" (Vide complet)
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
            SGF.createFile(To_String(Arg1), True); 
         end if;

      elsif Command = "touch" then
         if Arg1 /= "" then 
            SGF.createFile(To_String(Arg1), False); 
         end if;

      elsif Command = "cd" then
         if Arg1 /= "" then 
            SGF.changeDirectory(To_String(Arg1)); 
         end if;

      elsif Command = "rm" then
         -- RM est maintenant INTELLIGENT grâce à ton sgf.adb
         -- On passe l'argument brut (ex: "*.txt") et le SGF gère tout.
         if Arg1 /= "" then 
            SGF.delete(To_String(Arg1), SGF.getCurrentDirectory); 
         else
            Put_Line("Usage : rm <fichier_ou_pattern>");
         end if;

      elsif Command = "rmdir" then
         -- RMDIR est maintenant INTELLIGENT
         if Arg1 /= "" then 
            SGF.deleteDirectory(To_String(Arg1), SGF.getCurrentDirectory); 
         end if;

      elsif Command = "cp" then
         -- CP est maintenant INTELLIGENT
         -- Arg1 = Source (ex: *.txt), Arg2 = Destination (ex: backup/)
         if Arg1 /= "" and Arg2 /= "" then
            -- Attention à l'ordre des arguments de ta fonction copyRepoFile
            -- Dans ton code : (path => destination, copied_name => source)
            SGF.copyRepoFile(To_String(Arg2), To_String(Arg1), SGF.getCurrentDirectory);
         else
            Put_Line("Usage : cp <source> <dest>");
         end if;
      
      elsif Command /= "" then
         Put_Line("Commande inconnue : " & To_String(Command));
      end if;

   end loop;

end terminal;