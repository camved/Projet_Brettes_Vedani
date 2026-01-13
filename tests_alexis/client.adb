with Ada.Text_IO;                use Ada.Text_IO;
with Ada.Integer_Text_IO;        use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with System;                     use System;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Ada.Containers.Doubly_Linked_Lists; 
with sgf;                        use sgf;

procedure client is

   temp: P_file;

begin

   initRacine(root);
   menuCreate(current_directory);
   menuCreate(current_directory);
   menuCreate(current_directory);
   menuCreate(current_directory);
   displayFileContent(current_directory);
   menuChangeDirectory(current_directory);
   displayFile(current_directory);

end client;