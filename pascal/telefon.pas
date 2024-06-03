uses crt;
var i,j:word;
begin
for i:=1 to 6 do
begin
for j:=1 to 99 do
begin
crt.sound(1234);
delay(11);
nosound;
end;
delay(999);
end;
end.