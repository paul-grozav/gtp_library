uses Crt, Graph;
var
x,y,gd, Gm: Integer;
Color: Word;
P: Pointer;
Size: Word;
a:char;

procedure foc(a,b:integer);
var i,j:integer;
begin
for i:=a to 640 do
begin
putpixel(i,b,cyan);
putpixel(i,b+5,cyan);
putpixel(i+5,b,cyan);
putpixel(i+5,b+5,cyan);
putpixel(i+2,b+2,red);
for j:=1 to 9999 do begin end;
end;
end;

procedure pp(a,b:integer);
begin
{par}
setcolor(yellow);
line(a,b,a+9,b);
line(a,b+1,a+10,b+1);
{cap}
setfillstyle(solidfill,12);
setcolor(12);
bar3d(a,b+2,a+9,b+10,0,topoff);
{nas}
putpixel(a+10,b+6,12);
{ochii}
putpixel(a+9,b+3,cyan);
{gura}
setcolor(white);
line(a+8,b+8,a+9,b+8);
{gat}
setcolor(12);
line(a+4,b+11,a+4,b+13);
line(a+5,b+11,a+5,b+13);
line(a+6,b+11,a+6,b+13);
{vesta}
setfillstyle(solidfill,blue);
setcolor(blue);
bar3d(a,b+14,a+10,b+30,0,topoff);
{mana}
setfillstyle(solidfill,12);
setcolor(12);
bar3d(a+4,b+16,a+7,b+23,0,topoff);
bar3d(a+4,b+24,a+11,b+27,0,topoff);
bar3d(a+12,b+20,a+13,b+27,0,topoff);
{picior}
setfillstyle(solidfill,darkgray);
setcolor(darkgray);
bar3d(a+3,b+31,a+6,b+40,0,topoff);
{papuc}
setfillstyle(solidfill,blue);
setcolor(blue);
bar3d(a+3,b+40,a+9,b+43,0,topoff);
putpixel(a+9,b+43,black);
putpixel(a+9,b+40,black);
end;

begin
Gd := Detect;
InitGraph(Gd, Gm, '');
x:=10;
y:=45;
repeat
cleardevice;
pp(x,y);
case readkey of
#0:begin
        case readkey of
        #80:y:=y+2;
        #72:y:=y-2;
        #75:x:=x-2;
        #77:x:=x+2;
        end;
   end;
'x':begin closegraph; exit; end;
#27:begin closegraph; clrscr; writeln('HELP'); readln; end;
' ':foc(x+14,y+20);
end;
until a='x';
CloseGraph;
end.




