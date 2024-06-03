uses Crt, Graph;
var
i,Gd, Gm: Integer;
begin
Gd := Detect;
InitGraph(Gd, Gm, ' ');
for i:=1 to 320 do
begin
line(320,240,i*2-1,1);
end;

for i:=1 to 240 do
begin
line(320,240,640,i*2-1);
end;

for i:=320 downto 1 do
begin
line(320,240,i*2-1,480);
end;

for i:=240 downto 1 do
begin
line(320,240,1,i*2-1);
end;
setcolor(blue);
outtextxy(300,200,'Blue Hat');
Readln;
CloseGraph;
end.




