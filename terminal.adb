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


   SGF.initRacine(Racine_SGF);
   New_Line;

   loop
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
               -- ls -r dossier
               SGF.displayFileContentRecursive(To_String(Arg2), SGF.getCurrentDirectory);
            else
               -- ls -r (sur le courant)
               SGF.displayFileContentRecursive(".", SGF.getCurrentDirectory);
            end if;

         -- "ls dossier -r" 
         elsif Arg2 = "-r" then
            SGF.displayFileContentRecursive(To_String(Arg1), SGF.getCurrentDirectory);

         -- "ls dossier"
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
         if Arg1 /= "" then 
            SGF.delete(To_String(Arg1), SGF.getCurrentDirectory); 
         else
            Put_Line("Usage : rm <fichier_ou_pattern>");
         end if;

      elsif Command = "rm -r" then
         if Arg1 /= "" then 
            SGF.deleteDirectory(To_String(Arg1), SGF.getCurrentDirectory); 
         end if;

      elsif Command = "cp" then
         if Arg1 /= "" and Arg2 /= "" then
            SGF.copyRepoFile(To_String(Arg2), To_String(Arg1), SGF.getCurrentDirectory);
         else
            Put_Line("Usage : cp <source> <dest>");
         end if;
      
      elsif Command /= "" then
         Put_Line("Commande inconnue : " & To_String(Command));
      end if;

   end loop;

end terminal;