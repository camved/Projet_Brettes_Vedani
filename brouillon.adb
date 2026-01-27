procedure copy(to_be_copied : in P_file; new_parent : in P_file) is
   current_temp : P_file := SGF.current_directory;
   newly_created : P_file;
begin
   -- On se déplace temporairement pour créer le fichier au bon endroit
   SGF.current_directory := new_parent;
   
   -- 1. Création du fichier/dossier
   createFile (To_String(to_be_copied.nom), to_be_copied.isRepo);
   
   -- 2. On récupère le fichier qu'on vient de créer dans la liste des enfants
   -- Note : createFile l'ajoute normalement à la fin de la liste
   newly_created := new_parent.L_enfant.Last_Element;
   
   -- 3. On affecte le propriétaire (sgf.current_user)
   -- Adaptez le nom du champ (ex: proprietaire ou droits_acces) selon votre record
   newly_created.proprietaire := SGF.current_user; 
   
   -- Si vous avez aussi un champ taille à copier
   newly_created.taille := to_be_copied.taille;
   
   -- On restaure la position
   SGF.current_directory := current_temp;
   
end copy;