uses Crt, Graph,dos;
type but=(nobut,leftbut,rightbut,bothbut);
var
t,r,x,y,auxiliare,color,h,v,Gd, Gm: Integer;
ex: Word;
b:but;
event:boolean;
f:text;
a:string;

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

procedure paint;
var f:text;
    a:string;
    b:longint;
begin
{assign(f,'c:\paint.pic');append(f);
writeln(f,h);
writeln(f,v);
writeln(f,color);
close(f);}
putpixel(h,v,color);
setcolor(color);
str(t,a);
line(t,r,x,y);
outtext(a+'  ');for b:=1 to 999999 do begin end;
t:=-1;
r:=-1;
x:=-1;
y:=-1;
end;


procedure desktop;
begin
setbkcolor(lightblue);
end;

procedure paleta;
begin
SetFillStyle(solidfill,0);
Bar(0,440,40,460);
SetFillStyle(solidfill,1);
Bar(0,461,40,480);

SetFillStyle(solidfill,2);
Bar(41,440,80,460);
SetFillStyle(solidfill,3);
Bar(41,461,80,480);

SetFillStyle(solidfill,4);
Bar(81,440,120,460);
SetFillStyle(solidfill,5);
Bar(81,461,120,480);

SetFillStyle(solidfill,6);
Bar(121,440,160,460);
SetFillStyle(solidfill,7);
Bar(121,461,160,480);

SetFillStyle(solidfill,8);
Bar(161,440,200,460);
SetFillStyle(solidfill,9);
Bar(161,461,200,480);

SetFillStyle(solidfill,10);
Bar(201,440,240,460);
SetFillStyle(solidfill,11);
Bar(201,461,240,480);

SetFillStyle(solidfill,12);
Bar(241,440,280,460);
SetFillStyle(solidfill,13);
Bar(241,461,280,480);

SetFillStyle(solidfill,14);
Bar(281,440,320,460);
SetFillStyle(solidfill,15);
Bar(281,461,320,480);

rectangle(321,461,360,480);
rectangle(330,465,350,475);

rectangle(321,440,360,460);
line(321,440,360,460);
end;

begin
t:=-1;
r:=-1;
x:=-1;
y:=-1;
randomize;
Gd := Detect;
InitGraph(Gd, Gm, 'graph\');
desktop;
mouse_on;
event:=false;
repeat
begin
paleta;
mouse_status(b,h,v);h:=h shr ex;
if (b=rightbut) then event:=true;

if (b=leftbut) then
begin
if h>0 then
begin
if h<40 then
begin
if v>440 then
begin
if v<460 then
color:=0;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>0 then
begin
if h<40 then
begin
if v>461 then
begin
if v<480 then
color:=1;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>41 then
begin
if h<80 then
begin
if v>440 then
begin
if v<460 then
color:= 2;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>41 then
begin
if h<80 then
begin
if v>461 then
begin
if v<480 then
color:= 3;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>81 then
begin
if h<120 then
begin
if v>440 then
begin
if v<460 then
color:= 4;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>81 then
begin
if h<120 then
begin
if v>461 then
begin
if v<480 then
color:= 5;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>121 then
begin
if h<160 then
begin
if v>440 then
begin
if v<460 then
color:= 6;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>121 then
begin
if h<160 then
begin
if v>461 then
begin
if v<480 then
color:= 7;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>161 then
begin
if h<200 then
begin
if v>440 then
begin
if v<460 then
color:= 8;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>161 then
begin
if h<200 then
begin
if v>461 then
begin
if v<480 then
color:= 9;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>201 then
begin
if h<240 then
begin
if v>440 then
begin
if v<460 then
color:=10;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>201 then
begin
if h<240 then
begin
if v>461 then
begin
if v<480 then
color:=11;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>241 then
begin
if h<280 then
begin
if v>440 then
begin
if v<460 then
color:=12;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>241 then
begin
if h<280 then
begin
if v>461 then
begin
if v<480 then
color:=13;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>281 then
begin
if h<320 then
begin
if v>440 then
begin
if v<460 then
color:=14;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>281 then
begin
if h<320 then
begin
if v>461 then
begin
if v<480 then
color:=15;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>321 then
begin
if h<360 then
begin
if v>440 then
begin
if v<460 then
if auxiliare=0 then
auxiliare:=1
else
auxiliare:=0;
end;
end;
end;
end;


if (b=leftbut) then
begin
if h>321 then
begin
if h<360 then
begin
if v>461 then
begin
if v<480 then
auxiliare:=2;
end;
end;
end;
end;

if (b=leftbut) then
begin

if auxiliare=1 then
begin


if t=-1 then
begin
t:=h;
r:=v;
end
else
begin
x:=h;
y:=v;
paint;
end;


end;
putpixel(h-1,v-1,color);
end;

end;
until event;
CloseGraph;
assign(f,'c:\paint.pic');reset(f);
close(f);

end.
