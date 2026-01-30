with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with memoire;
with System;                     use System;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Ada.Containers.Doubly_Linked_Lists; 
with sgf;                        use sgf;
with Ada.Exceptions;
with memoire;                    use memoire;

procedure client is

   temp: P_file;
   memoire_SGF : Mem;

begin

   switchUser;
   initMem (memoire_SGF);
   initRacine(root, memoire_SGF);
   interactiveMenu(current_directory, memoire_SGF);
end client;