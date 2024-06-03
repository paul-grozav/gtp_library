uses Crt, Graph,dos;
type but=(nobut,leftbut,rightbut,bothbut);
var
h,v,Gd, Gm: Integer;
ex: Word;
b:but;
event:boolean;

procedure mouse_on;
var regs: registers;
    h,v:integer;
begin
regs.ax:=1;
intr($33,regs);
end;

procedure mouse_status(var b:but;var h,v:integer);
var regs: registers;
begin
with regs do
begin
ax:=3;
intr($33,regs);
h:=cx;
v:=dx;
case bx and 3 of
0:b:=nobut;
1:b:=leftbut;
2:b:=rightbut;
3:b:=bothbut;
end;
end;
end;


procedure desktop;
begin
setbkcolor(lightblue);
end;

procedure button(a,b,c,d:integer);
begin
SetFillStyle(solidfill,7);
bar(a+2,b+2,c-2,d-2);
{lumina}
line(a,b,a,d);
line(a+1,b,a+1,d-1);
line(a,b,c,b);
line(a+1,b+1,c-1,b+1);
{umbra}
setcolor(8);
line(a+1,d,c,d);
line(c,b+1,c,d);
line(c-1,b+2,c-1,d-1);
line(a+2,d-1,c-1,d-1);
setcolor(white);
end;

begin
randomize;
Gd := Detect;
InitGraph(Gd, Gm, 'graph\');
desktop;
mouse_on;
event:=false;
repeat
begin
mouse_status(b,h,v);h:=h shr ex;
if (b=rightbut) then event:=true;
button(30,30,400,400);
end;
until event;
CloseGraph;
end.




