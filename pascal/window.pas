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

procedure win(a,b,c,d:integer; x:string);
begin
b:=b+17;
SetFillStyle(solidfill,7);
bar(a+2,b+2,c-2,d-2);
{lumina}
setcolor(white);
line(a,b-17,a,d);
line(a+1,b-16,a+1,d-1);
line(a,b-16,c-2,b-16);
line(a+1,b-17,c-1,b-17);
{umbra}
setcolor(8);
line(a+1,d,c,d);
line(c,b-16,c,d);
line(c-1,b-16,c-1,d-1);
line(a+2,d-1,c-1,d-1);
setcolor(white);
{title bar}
SetFillStyle(solidfill,blue);
bar(a+2,b-15,c-2,b);
outtextxy(a+20,b-10,x);
setcolor(red);
outtextxy(a+3,b-10,'BH');
{intre}
setcolor(white);
line(a+2,b+1,c-2,b+1);
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
win(0,0,639,479,'TEDI');
end;
until event;
CloseGraph;
end.


