uses crt;
var a:word;
begin
a:=100;
repeat
inc(a,100);
crt.sound(a);
delay(33);
nosound;
until a>3500
end.