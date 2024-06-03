uses crt;
begin
case readkey of
#0:begin
   case readkey of
     #72:writeln('Up');
     #80:writeln('Down');
     #75:writeln('Left');
     #77:writeln('Right');
     #16:writeln('Alt+Q');
     #59:writeln('F1');
     #115:writeln('Ctrl+Left');
     #114:writeln('Ctrl+Print Screen');
   end;
   end;
end;
readln;
end.