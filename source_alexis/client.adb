with SGF;            use SGF;
with Ada.Text_IO;    use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure client is

   racine: file;

begin

   initRacine (racine);
   Put(racine.droits_acces);

end client;