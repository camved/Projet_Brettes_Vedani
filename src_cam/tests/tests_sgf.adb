with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with SGF; -- On importe ton paquet

procedure Test_SGF is

   Ma_Racine : SGF.File; 

begin

   Put("Test de initRacine");
   SGF.initRacine(Ma_Racine);
   
   if Ma_Racine.nom /= To_Unbounded_String("/") then
      Put_Line("ÉCHEC : Le nom n'est pas correct.");
      Put_Line("Attendu : /");
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
   Put("Test create file");
   
   SGF.createFile ("test");
   
  

end Test_SGF;