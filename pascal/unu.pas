uses Crt, Graph,dos;
type but=(nobut,leftbut,rightbut,bothbut);
var
h,v,Gd, Gm: Integer;
o,p,q,r,hour,m,s,hund,ex: Word;
b:but;
event:boolean;

procedure mouse_on;
var regs: registers;
    h,v:integer;
begin
regs.ax:=1;
intr($33,regs);
end;

procedure screensaver;
var X1,Y1,X2,Y2,b:integer;
    a:longint;
begin
b:=random(2);
case b of
1:
begin
repeat
for a:=1 to 999999 do begin end;
SetColor(Random(GetMaxColor)+1);
LineTo(Random(GetMaxX),
Random(GetMaxY));
until KeyPressed;
SetFillStyle(solidfill,lightblue);
Bar(0,0,640,480);
end;

2:
begin
repeat
{for a:=1 to 99 do begin end;}
setcolor(random(red));
X1 := Random(GetMaxX);
Y1 := Random(GetMaxY);
X2 := Random(GetMaxX - X1) + X1;
Y2 := Random(GetMaxY - Y1) + Y1;
Rectangle(X1, Y1, X2, Y2);
until KeyPressed;
SetFillStyle(solidfill,lightblue);
Bar(0,0,640,480);
end;
end;
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

begin
randomize;
Gd := Detect;
InitGraph(Gd, Gm, 'graph\');
desktop;
mouse_on;
event:=false;
GetTime(o,p,q,r);
repeat
begin
GetTime(hour,m,s,hund);
if hund-r=0 then
begin
if s-q=10 then
begin
if m-p=0 then
begin
if hour-o=0 then
screensaver;
end;
end;
end;
mouse_status(b,h,v);h:=h shr ex;
if (b=rightbut) then event:=true;
end;
until event;
CloseGraph;
end.




