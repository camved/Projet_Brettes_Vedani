with Ada.Text_IO; use Ada.Text_IO;

package memoire is

   type Block_available;

   type P_block_available is access Block_available;
   
   type Mem is record
      first_Element : P_block_available;
   end record;
   
   type Block_available is record
      first_bit  : Natural;
      size   : Natural;
      p_next : P_block_available; 
   end record;

   max_size  : Integer := 1073741824; -- 1 To en Ko

   Erreur_Disque_Plein : Exception;

   --Nom : initMem
   --Objectif : Initialiser le système de mémoire (création du premier bloc libre)
   --Paramètres :
      --memoire : out Mem
   --Pré : Variable memoire non initialisée
   --Post : memoire contient un bloc libre initial (ex: 1 Go) et pointeur de tête valide
   procedure initMem (memoire : out Mem);

   --Nom : allocateMem
   --Objectif : Allouer un bloc de mémoire d'une taille donnée
   --Paramètres :
      --memoire : in out Mem
      --size : in Integer (Taille demandée)
      --return : Integer (Adresse du bloc alloué)
   --Pré : size > 0, initMem a été appelé
   --Post :
      --Retourne l'adresse de début du bloc alloué
      --Exception Erreur_Disque_Plein levée si pas assez d'espace contigu
   function allocateMem(memoire : in out Mem; size : in Integer) return Integer;

   --Nom : freeMem
   --Objectif : Libérer un bloc de mémoire précédemment alloué
   --Paramètres :
      --memoire : in out Mem
      --address : in Integer (Adresse du bloc à libérer)
      --size : in Integer (Taille du bloc à libérer)
   --Pré : Le bloc à cette adresse était occupé
   --Post : L'espace est marqué comme libre et potentiellement fusionné avec les voisins
   procedure freeMem(memoire : in out Mem; address : in Integer; size : in Integer);

   --Nom : Afficher_Memoire
   --Objectif : Afficher l'état actuel de la mémoire (blocs libres) pour le débogage
   --Paramètres :
      --memoire : in Mem
   --Pré : initMem appelé
   --Post : Affiche la liste chaînée des blocs libres sur la sortie standard
   procedure Afficher_Memoire(memoire : in Mem);

end memoire;