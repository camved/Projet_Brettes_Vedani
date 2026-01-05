with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;

package SGF is 

   type P_file is access file;

   type file is record

      nom: unbounded_string;
      droits_acces: String (1..9);
      taille: Integer;
      rep_parent: P_file;
      L_enfant: P_file;
      isRepo: Boolean;
   
   end record;

   procedure initRacine (root: in out file) is
   begin

      root.nom := To_Unbounded_String("/");
      root.droits_acces := "rwxrwxrwx";
      root.taille := 1; --Volume total divisé par 10Ko pour qu'on ne manie qu'une unité simple
      root.rep_parent := null;
      root.L_enfant := null;
      root.isRepo := True;

   end initRacine;

   function getActualFile(actual_file : in file ; actual_name : out String) is
   begin
   end getActualFile;


   function getPath( ) is
   begin
   end getPath;

end SGF;

