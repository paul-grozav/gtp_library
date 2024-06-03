uses Crt, Graph;
var
Gd, Gm,m: Integer;
raza,x,y:word;
procedure desenare(N:byte);
var color:word;
begin
for color:=4 to 500 do
begin
setcolor(color div 16);
arc(x,y,0,300,raza-color div N);
if odd(color) then inc(Y);
inc(x);
end
end;

begin
Gd:= VGA;
gm:=VGAHi;
InitGraph(Gd, Gm, ' ');
raza:=140;
for m:=1 to 3 do
begin
x:=140;
y:=150;
desenare(M)
end;
Readln;
CloseGraph
end.




