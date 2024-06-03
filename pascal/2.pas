uses crt;
var a:word;
begin
a:=391;
crt.sound(a);
delay(210);
inc(a,247);
crt.sound(a);
delay(410);
nosound;
end.