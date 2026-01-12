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

   --  initRacine (root);
   --  displayFile(current_directory);
   --  createFile ("alexisTest", True);
   --  displayFile(current_directory);
   --  createFile("/alexisTest2", False);
   --  displayFile(current_directory);
   --  createFile ("/alexisTest/sicafonctionnejesuislegoat", False);
   --  --changeDirectory ("/alexisTest/sicafonctionnejesuislegoat");
   --  changeDirectory("alexisTest");
   --  displayFile(current_directory);
   
   initRacine (root);
   temp := current_directory;
   displayFile(current_directory);
   createFile ("alexisTest", True);
   displayFile(current_directory);
   createFile("/alexisTest2", False);
   displayFile(current_directory);
   changeDirectory("alexisTest");
   createFile ("sicafonctionnejesuislegoat", False);
   createFile ("ProutiProuta", True);
   --changeDirectory ("/alexisTest/sicafonctionnejesuislegoat");
   displayFile(current_directory);
   changeDirectory("ProutiProuta");
   displayFile(current_directory);
   New_Line;
   createFile ("camilleGOAT", False);
   Put(To_String(extractParent("/alexisTest/ProutiProuta/camilleOAT", current_directory).nom)); 


   --  current_directory := temp;
   --  displayFile(current_directory);
   --  Put(To_String(parsePath("/alexisTest/ProutiProuta/camilleGOAT", current_directory).nom)); 

end client;