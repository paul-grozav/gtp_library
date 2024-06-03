uses crt;
var a:string;
i:integer;

procedure punct;
begin
sound(321);
delay(300);
nosound;
delay(800);
end;

procedure linie;
begin
sound(321);
delay(900);
nosound;
delay(500);
end;

begin
clrscr;
write('Introduceti textul:');readln(a);
clrscr;
for i:=1 to length(a) do
begin
case a[i] of
'a':begin delay(1000); write(a[i]); punct; linie; end;
'b':begin delay(1000); write(a[i]); linie; punct; punct; punct; end;
'c':begin delay(1000); write(a[i]); linie; punct; linie; punct; end;
'd':begin delay(1000); write(a[i]); linie; punct; punct; end;
'e':begin delay(1000); write(a[i]); punct; end;
'f':begin delay(1000); write(a[i]); punct; punct; linie; punct; end;
'g':begin delay(1000); write(a[i]); linie; linie; punct; end;
'h':begin delay(1000); write(a[i]); punct; punct; punct; punct; end;
'i':begin delay(1000); write(a[i]); punct; punct; end;
'j':begin delay(1000); write(a[i]); punct; linie; linie; linie; end;
'k':begin delay(1000); write(a[i]); linie; punct; linie; end;
'l':begin delay(1000); write(a[i]); punct; linie; punct; punct; end;
'm':begin delay(1000); write(a[i]); linie; linie; end;
'n':begin delay(1000); write(a[i]); linie; punct; end;
'o':begin delay(1000); write(a[i]); linie; linie; linie; end;
'p':begin delay(1000); write(a[i]); punct; linie; linie; punct;  end;
'q':begin delay(1000); write(a[i]); linie; linie; punct; linie; end;
'r':begin delay(1000); write(a[i]); punct; linie; punct; end;
's':begin delay(1000); write(a[i]); punct; punct; punct; end;
't':begin delay(1000); write(a[i]); linie; end;
'u':begin delay(1000); write(a[i]); punct; punct; linie; end;
'v':begin delay(1000); write(a[i]); punct; punct; punct; linie; end;
'w':begin delay(1000); write(a[i]); punct; linie; linie; end;
'x':begin delay(1000); write(a[i]); linie; punct; linie; linie; end;
'y':begin delay(1000); write(a[i]); linie; punct; linie; linie; end;
'z':begin delay(1000); write(a[i]); linie; linie; punct; punct; end;
'1':begin delay(1000); write(a[i]); punct; linie; linie; linie; linie; end;
'2':begin delay(1000); write(a[i]); punct; punct; linie; linie; linie; end;
'3':begin delay(1000); write(a[i]); punct; punct; punct; linie; linie; end;
'4':begin delay(1000); write(a[i]); punct; punct; punct; punct; linie; end;
'5':begin delay(1000); write(a[i]); punct; punct; punct; punct; punct; end;
'6':begin delay(1000); write(a[i]); linie; punct; punct; punct; punct; end;
'7':begin delay(1000); write(a[i]); linie; linie; punct; punct; punct; end;
'8':begin delay(1000); write(a[i]); linie; linie; linie; punct; punct; end;
'9':begin delay(1000); write(a[i]); linie; linie; linie; linie; punct; end;
'0':begin delay(1000); write(a[i]); linie; linie; linie; linie; linie; end;
'.':begin delay(1000); write(a[i]); punct; linie; punct; linie; punct; linie; end;

end;
end;
end.