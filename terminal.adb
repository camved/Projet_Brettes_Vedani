with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Strings.Fixed;   use Ada.Strings.Fixed;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Maps;    use Ada.Strings.Maps;
with SGF;                 use SGF;

procedure terminal is

   commandLine : String (1 .. 100);
   Last         : Natural;
   
   Full_Input   : Unbounded_String;
   Cmd          : Unbounded_String;
   Arg          : Unbounded_String;
   
   Space_Index  : Natural;
   Ma_Racine    : SGF.File;

begin
   SGF.initRacine(Ma_Racine);

   Put_Line("               #########");
   Put_Line("              ##  ####  #"); 
   Put_Line("              ############");
   Put_Line("              ############");
   Put_Line("              ### ");
   Put_Line("              #########");
   Put_Line("  #          ####");
   Put_Line("  ###      ############");
   Put_Line("   ###    #########   #");
   Put_Line("    ###  #########");
   Put_Line("     ############");
   Put_Line("      ##########");
   Put_Line("        #     ##");
   Put_Line("        ##     #");
   Put_Line("               ##");
   New_Line;
   Put_Line("=============================================");
   Put_Line("    Welcome to the fedoRAPTOR terminal !");
   Put_Line("=============================================");
   New_Line;

   if command_line then 
   end if;

end terminal;