program king;

/////////////////////////////////////////////////////////////////////////////
// King of the hill
/////////////////////////////////////////////////////////////////////////////

uses
   math,
   display,
   inifiles;

{$i readstr.inc}

procedure introduction;
begin
   clrscr;
   textcolor(yellow);
   writeln('Welcome to King of the hill v1.0'+lineending);
   textcolor(lightgreen);
   writeln('This game allows you to login and do certain commands only once');
   writeln('every 12 hours. The game is straight forward, every time you login');
   writeln('you will want to press space to generate more fighters for your');
   writeln('team. When you feel that you have a large enough army of fighters');
   writeln('you "c"harge the hill. If you are successful, you are awarded');
   writeln('King Of The Hill. Where you will remain until someone else builds');
   writeln('a large enough team of fighters to overthrough your reign.');
   writeln('');
   writeln('Everytime someone attacks you, your team will sustain injuries.');
   writeln('These injuries will heal over 24 hours, or if you come down from');
   writeln('the hill for a solid 60 minutes without being attacked.'+lineending);
   textcolor(white);
end;

function generatefighters(pn:string):longint;
begin
   result:=random(10,100);
   writeln(pn,', you now have ',result,' more fighters.');
end;

procedure playgame;
const
   spinner=['0','O','o','.','o','O'];

var
   playername,upn:string;
   ch:char;
   spin:byte;
   spindelay:byte;
   inifile:TIniFile;
   fighters:largeint;
   currentking:string;
   lastmove:TTimestamp;

begin
   inifile.init('king.ini');
   currentking:=inifile.readstring('current','king','');
   write('what is your name? ');
   playername:=readstr(25);
   upn:=uppercase(playername);
   lastmove:=inifile.readtimestamp(upn,'laston',0);
   if lastmove=0 then begin
      textcolor(lightcyan);
      fighters:=random(80,250);
      writeln(playername,' you have inherited a small team of ',fighters,' fighters.');
      inifile.writetimestamp(upn,'laston',timestamp);
      inifile.writeint64(upn,'fighters',fighters);
      textcolor(white);
   end
   else begin
      textcolor(lightcyan);
      fighters:=inifile.readint64(upn,'fighters',0);
      writeln(playername,' you currently have a team of ',fighters,' fighters.'+lineending);
      textcolor(white);
   end;

   writeln(playername,' press spacebar to generate more fighters, or "c" to charge the hill.');
   writeln('When you are finished with todays commands, press escape to exit.'+lineending);
   ch:=#0;
   spin:=0;
   spindelay:=0;
   while ch!=#27 do begin
      if keypressed then begin
         ch:=readkey;
         if ch=#32 then begin
            if lastmove+86400<timestamp then begin
               textcolor(yellow);
               fighters+=generatefighters(playername);
               writeln('Giving you a total team of ',fighters,' fighters.');
               textcolor(white);
               lastmove:=timestamp;
               inifile.writetimestamp(upn,'laston',lastmove);
               inifile.writeint64(upn,'fighters',fighters);
            end
            else begin
               textcolor(lightred);
               if ((lastmove+86400)-lastmove) div 60<120 then begin
                  writeln('You cannot generate more fighters for another ',((lastmove+86400)-timestamp) div 60,' minutes.');
               end
               else begin
                  writeln('You cannot generate more fighters for another ',((lastmove+86400)-timestamp) div 3600,' hours and ',(((lastmove+86400)-timestamp) mod 3600) div 60,' minutes.');
               end;
               textcolor(white);
            end;
         end
         else if (ch='c') or (ch='C') then begin
// to be coded next round //
         end;
      end
      else begin
         write(spinner[spin]+#8);
         yield(1);
         inc(spindelay);
         if spindelay>250 then begin
            inc(spin);
            if spin>5 then spin:=0;
            spindelay:=0;
         end;
      end;
   end;
   inifile.free;
end;

begin
   randomize;
   introduction;
   playgame;
end.
