with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;

package SGF is 

   type file; --Déclaration partielle pour permettre le pointeur suivant

   type P_file is access file;

   type file is record

      nom: unbounded_string;
      droits_acces: String (1..9);
      taille: Integer;
      rep_parent: P_file;
      L_enfant: P_file;
      isRepo: Boolean;
   
   end record;

   
   VOID_POINTER_ERROR : exception;

   procedure initRacine (root: in out file);

   function getActualFile(actual_file : in P_file) return Unbounded_String;

end SGF;