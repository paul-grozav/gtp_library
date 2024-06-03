uses graph,crt,dos;
type
but=(nobut,leftbut,rightbut,bothbut); {butoane apasate}
const
cheight=20; cwidth=40; {dimensiuni casete}
noaction=0;
textoutput=1;
linetracing=2;
curvetracing=3;
var
dr,mo,v,x0,y0,x1,y1,i,bkcol,color,font,action,h,aa,bb:integer;
b:but;
event,posset:boolean;
maxy,maxx,limfy,limfx,limcx,limx,limy,dwidth,halfc,size,ex:word;
c:char;

{interfata cu driverul de mouse}
function mouse_inited:boolean;
var regs:registers;
begin
if memw[$0000 : $33 *4]=0 then
mouse_inited:=false
else
begin
regs.ax:=0;
intr($33,regs);
mouse_inited:= regs.ax <>0;
end;
end;

procedure mouse_setcursor;
var regs:registers;
begin
regs.ax:=10;
regs.bx:=0;    {software text cursor}
regs.cx:=$77FF;
regs.dx:=$7700;
intr($33,regs);
end;

procedure mouse_setareax(l,r:integer);
var regs:registers;
begin
regs.ax:=7;
regs.cx:=l-1;
regs.dx:=r-1;
intr($33,regs);
end;

procedure mouse_setareay(t,b:integer);
var regs:registers;
begin
regs.ax:=8;
regs.cx:=t-1;
regs.dx:=b-1;
intr($33,regs);
end;

procedure mouse_showcursor;
var regs: registers;
    h,v:integer;
begin
regs.ax:=1;
intr($33,regs);
end;

procedure mouse_hidecursor;
var regs: registers;
    h,v:integer;
begin
regs.ax:=2;
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

procedure mouse_setpos(h,v:integer);
var regs:registers;
begin
regs.ax:=4;
regs.cx:=h-1;
regs.dx:=v-1;
intr($33,regs);
end;

{programul principal}
begin
if not mouse_inited then
begin
     write('Mouseu nu-i instalat!');
     halt(1);
end;

{initializare grafica}

dr := Detect;
InitGraph(dr, mo, 'graph\');
{daca moduri grafice cu 320 coloane, atunci coordonata h a mouseului corespunde coloanei h div 2 a ecranului}
if ((dr=cga) or (dr=mcga)) and (mo<=3) then
ex:=1
else
ex:=0;

{deseneaza legenda}
cleardevice;
maxx:=getmaxx;
maxy:=getmaxy;
halfc:=(getmaxcolor + 1) div 2;
bkcol:=halfc-1;
setfillstyle(solidfill,bkcol);
bar3d(0,0,maxx,maxy,0,topoff);  {fondul}
for i:=0 to getmaxcolor do
begin
     setfillstyle(solidfill,i);
     aa:=(i mod halfc) * cwidth;
     bb:=maxy - 2*cheight +(i div halfc)*cheight;
     bar3d(aa,bb+1,aa+cwidth-1,bb+cheight,0,topoff);
end;
settextjustify(centertext,centertext);
limfx:= halfc*cwidth;
limy:= maxy-2*cheight;
for i:=1 to 4 do
begin       {siglele cu fonturi}
            if i=smallfont then size:=4 else size:=2;
            settextstyle(i,horizdir,size);
            rectangle(limfx+(i-1)*cwidth,limy+1,limfx+i*cwidth-1,limy+cheight);
            outtextxy(limfx+(i-1)*cwidth+cwidth div 2,limy+cheight div 2, 'A');
end;
dwidth:=cwidth div 2;
limfy:=maxy-cheight;
settextstyle(smallfont,horizdir,4);
for i:=1 to 8 do
begin    {siglele cu marimi ale caracterelor}
         outtextxy(limfx+(i-1)*dwidth+dwidth div 2,limfy+cheight div 2-1,chr(ord('0')+i));
         line(limfx+i*dwidth-1,limfy,limfx+i*dwidth-1,maxy);
end;
line(limfx,maxy,limfx+4*cwidth-1,maxy);
limcx:=(halfc+4)*cwidth;
limx:=(halfc+5)*cwidth;
rectangle(limcx,limy+1,limx-1,limfy);
rectangle(limcx,limfy+1,limx-1,maxy);
arc(limcx+cwidth+cwidth div 2,limfy,30,150,cheight div 2);
{sigla pt curbe}
line(limcx+2,maxy-4,limx-3,limfy+5);{sigla pentru segmente
{stabileste ecranul pentru mouse si pozitia init a cursorului}
mouse_setareax(1,maxx shl ex);
mouse_setareay(1,maxy);
mouse_showcursor;
mouse_setpos(1,1);

{diverse instalari}
settextjustify(lefttext,bottomtext);
size:=1;
font:=defaultfont;
action:=noaction;

while true do
begin
     {circleaza pana la apasarea pe un buton sau pe o tasta}
     repeat
     event:=false;
     mouse_status(b,h,v);h:=h shr ex;
     if (b=leftbut) or (b=rightbut) then event:=true;
     until event or keypressed;
     {daca buton}
     if event then
     begin
          {butonul drept apasat - termina programul}
          if b=rightbut then
          begin
               closegraph;
               exit;
          end;
          {butonul sting a fost apasat}
          if (v>limy) and (h<limx) then {daca in legenda}
          begin
               if h<limfx then {daca in culori}
               begin
                    color:=h div cwidth +((v-limy) div cheight)*halfc;
                    setcolor(color);
               end
               else
               {}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}
               {}                              {}
               {}                              {}
               {}                              {}
               {}                              {}
               {}                              {}
               {}                              {}
               {}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}
               if h<limcx then
               if v<=limfy
               then     {daca in fonturi}
               begin
                    font:=(h-limfx) div cwidth + 1;
                    settextstyle(font,horizdir,size);
                    action:=textoutput;
                    posset:=false;
               end
               else  {daca in tabelul de marimi}
               begin
                    size:=(h-limfx) div dwidth + 1;
                    settextstyle(font,horizdir,size);
               end
               else
               if v<=limfy then
               action:=curvetracing  {trasare curbe}
               else action:=linetracing {trasare drepte}
               end
               else  {butonul stang apasat in zona de desen}
               case action of
               textoutput:begin
                                moveto(h,v);
                                posset:=true;
                          end;
               curvetracing:while b=leftbut do
                                 begin
                                     if (v<=limy) or (h>= limx) then
                                     begin
                                          mouse_hidecursor;
                                          putpixel(h,v,color);
                                          mouse_showcursor;
                                     end;
                                     mouse_status(b,h,v);
                                     h:=h shr ex;
                                 end;
               linetracing:begin
                                {trasarea se face prin combinare cu fontul, de aceea corecteaza culoarea inainte de trasare}
                                setwritemode(xorput);
                                setcolor(color xor bkcol);
                                x0:=h;  x1:=v; {start segment}
                                y0:=h;  y1:=v; {stop segment}
                                mouse_hidecursor;
                                line(x0,y0,x1,y1);{traseaza linie}
                                mouse_showcursor;
                                while b=leftbut do
                                begin
                                     if (h<>x1) or (v<>y1) then
                                     begin
                                          mouse_hidecursor;
                                          line(x0,y0,x1,y1);
                                          {sterge linie}
                                          mouse_showcursor;
                                          if (v<=limy) or (h>=limx) then
                                          begin
                                               x1:=h;
                                               y1:=v;
                                               mouse_hidecursor;
                                               line(x0,y0,x1,y1);
                                               mouse_showcursor;
                                          end;
                                     end;
                                     mouse_status(b,h,v);h:=h shr ex;
                                end;
                                setwritemode(copyput);
                                setcolor(color xor bkcol);
               end;
          end;{case}
     end{if event}
     else {keypressed}
     begin
          c:=readkey;
          if c=#0 then
          begin
               c:=readkey;
               c:=#0;
          end;
          if (action=textoutput) and posset and (ord(c)>31) and (ord(c)<128) then
          begin
               mouse_hidecursor;
               outtext(''+c);
               mouse_showcursor;
          end
          else
          begin
               sound(500); delay(10); nosound;
          end;
     end;
end;{while}
end.











