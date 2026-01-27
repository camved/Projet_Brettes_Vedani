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

   --Nom : copyFile (cp)
   --Objectif : copier le fichier ou le rep dans un autre repertoire de facon recurssive si le rep a des enfants
   --Paramètres : path in, type String,  copied_name_or_path in, type String, current_dir : P_file 
   --Pré : copied existe dans le repertoire designe et le chemin est valide pour acceder au parent
   --Post : le fichier est copié au bon endroit
   --Test : être en mesure de vérifier que le fichier copié est au bonne endroit et identique au premier
   procedure initMem (memoire : out Mem);

   function allocateMem(memoire : in out Mem; size : in Integer) return Integer;

   procedure freeMem(memoire : in out Mem; address : in Integer; size : in Integer);



end memoire;