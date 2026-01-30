with Ada.Text_IO; use Ada.Text_IO;
with memoire;     use memoire;

procedure Test_Memoire is
   M : Mem;
   Addr1, Addr2, Addr3, Addr4 : Integer;
begin
   Put_Line("=== DEBUT DES TESTS ===");

   -- 1. Initialisation
   Put_Line(">>> Initialisation de la mémoire");
   initMem(M);
   Afficher_Memoire(M);

   -- 2. Allocations
   Put_Line(">>> Allocation de 100 (Addr1) et 50 (Addr2)");
   Addr1 := allocateMem(M, 100);
   Addr2 := allocateMem(M, 50);
   Put_Line("   -> Addr1 : " & Integer'Image(Addr1));
   Put_Line("   -> Addr2 : " & Integer'Image(Addr2));
   Afficher_Memoire(M);

   Put_Line(">>> Allocation de 200 (Addr3)");
   Addr3 := allocateMem(M, 200); 
   Afficher_Memoire(M);

   -- 3. Libération simple (sans fusion immédiate si au milieu)
   -- On libère le bloc du milieu (Addr2, taille 50)
   Put_Line(">>> Libération de Addr2 (Taille 50)");
   freeMem(M, Addr2, 50);
   Afficher_Memoire(M);

   -- 4. Allocation qui remplit exactement un trou
   Put_Line(">>> Allocation de 50 (Doit reprendre l'ancien emplacement de Addr2)");
   Addr4 := allocateMem(M, 50);
   Put_Line("   -> Addr4 : " & Integer'Image(Addr4));
   Afficher_Memoire(M);

   -- 5. Test de saturation
   Put_Line(">>> Tentative de saturation (Allocation grosse taille)");
   declare
      Big_Addr : Integer;
   begin
      -- Supposons que max_size est grand, on essaye de tout prendre
      -- Ajuste la valeur ci-dessous selon ton 'max_size' défini dans le package
      Big_Addr := allocateMem(M, 2000000000); 
   exception
      when Erreur_Disque_Plein =>
         Put_Line("   [SUCCES] Exception Erreur_Disque_Plein levée correctement.");
   end;

   -- 6. Test de fusion (Coalescence)
   -- On nettoie un peu
   initMem(M); 
   Addr1 := allocateMem(M, 10); -- Bloc 1
   Addr2 := allocateMem(M, 10); -- Bloc 2
   Addr3 := allocateMem(M, 10); -- Bloc 3
   
   Put_Line(">>> Préparation fusion : 3 blocs alloués.");
   Afficher_Memoire(M); -- Le reste est libre
   
   Put_Line(">>> Libération Bloc 1 et Bloc 3 (trous non contigus)");
   freeMem(M, Addr1, 10);
   freeMem(M, Addr3, 10);
   Afficher_Memoire(M);

   Put_Line(">>> Libération Bloc 2 (Doit fusionner avec 1 et 3 pour refaire un gros bloc)");
   freeMem(M, Addr2, 10); 
   Afficher_Memoire(M);

   Put_Line("=== FIN DES TESTS ===");

end Test_Memoire;