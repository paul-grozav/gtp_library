uses crt;
var i,j:word;
begin
for i:=1 to 4 do
for j:=401 to 412 do
begin
crt.sound(i);
delay(11);
crt.sound(j);
delay(11);
nosound;
end;
end.