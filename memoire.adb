with Ada.Unchecked_Deallocation;

package body memoire is

   procedure Free is new Ada.Unchecked_Deallocation(Block_available, P_block_available);

   procedure initMem (memoire : out Mem) is
   begin
      memoire.first_Element := new Block_available'(first_bit => 1,
                                                    size      => max_size,
                                                    p_next    => null); 
   end initMem;

   function allocateMem(memoire : in out Mem; size : in Integer) return Integer is

      current_block : P_block_available := memoire.first_Element; 
      previous      : P_block_available := null;
      new_adress : Integer;
   begin

      while current_block /= null loop
         if current_block.size >= size then

            new_adress := current_block.first_bit;

            if current_block.size = size then
               if previous = null then
                  memoire.first_Element := current_block.p_next;
               else
                  previous.p_next := current_block.p_next;
               end if;
               Free(current_block);
            else
               current_block.first_bit := current_block.first_bit + size;
               current_block.size := current_block.size - size;
            end if;

            return new_adress; 
         end if;

         previous      := current_block;
         current_block := current_block.p_next;
      end loop;

      raise Erreur_Disque_Plein;
      
   end allocateMem;

   procedure freeMem(memoire : in out Mem; address : in Integer; size : in Integer) is
      current  : P_block_available := memoire.first_Element;
      previous : P_block_available := null;
      new_block : P_block_available;

   begin
      -- 1. Trouver l'emplacement
      while current /= null and then current.first_bit < Address loop
         previous := current;
         current  := current.p_next;
      end loop;

      -- 2. Essayer de fusionner avec le PRECEDENT (Gauche)
      if previous /= null and then 
         (previous.first_bit + previous.size = address) 
      then
         -- On agrandit le précédent tout de suite !
         previous.size := previous.size + size;

         -- Maintenant, on regarde si ce précédent agrandi touche le SUIVANT (Droite)
         if current /= null and then 
            (previous.first_bit + previous.size = current.first_bit) then
            
            -- Fusion totale : on absorbe le suivant
            previous.size := previous.size + current.size; 
            previous.p_next := current.p_next;           
            Free(current);                                 
         end if;
         
         return; -- Travail terminé
      end if;

      -- 3. Essayer de fusionner avec le SUIVANT (Droite) seulement
      -- (Si on arrive ici, c'est qu'on n'a pas fusionné avec le précédent)
      if current /= null and then 
         (Address + Size = current.first_bit) then
         
         current.first_bit := Address;
         current.size := current.size + Size;
         
         return;
      end if;

      -- 4. Pas de fusion possible : Insertion d'un nouveau bloc
      new_block := new Block_available'(first_bit => Address, 
                                       size            => Size, 
                                       p_next         => current); 

      if previous = null then
         Memoire.first_Element := new_block;
      else
         previous.p_next := new_block;
      end if;

   end freeMem;

   procedure Afficher_Memoire(memoire : in Mem) is
      current : P_block_available := memoire.first_Element;
   begin
      Put_Line("-----------------------------------------------------");
      Put_Line("ETAT DE LA MEMOIRE (Liste des blocs libres) :");
      
      if current = null then
         Put_Line("  [MEMOIRE PLEINE] (Aucun bloc libre)");
      else
         while current /= null loop
            Put("  [Adresse :" & Integer'Image(current.first_bit) & 
                " | Taille :" & Integer'Image(current.size) & " ]");
                
            if current.p_next /= null then
               Put(" -> ");
            end if;
            
            current := current.p_next;
         end loop;
         New_Line;
      end if;
      Put_Line("-----------------------------------------------------");
   end Afficher_Memoire;

end memoire;