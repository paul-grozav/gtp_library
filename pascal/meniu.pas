uses objects,app,drivers,menus,views;
const
notitle='tedi';
maxwindows=255;
cmopen=100;
cmsunet=123;
cmculori=124;
nrFereastra: integer=0;
winN: set of 1..maxWindows=[];
type
PEx=^ex;
Ex=object(tapplication)
constructor init;
procedure handleevent(var event:tevent);
virtual;
procedure idle;virtual;
procedure initmenubar;virtual;
procedure initstatusline;virtual;
procedure openwindow(wtitle:string);
end;
Pfereastra=^fereastra;
fereastra=object(twindow)
constructor init(wtitle:string);
procedure close;virtual;
function getwindownumber:integer;
procedure putwindownumber;
end;

constructor ex.init;
begin
tapplication.init;
if paramcount>0 then openwindow(paramstr(1))
end;

procedure ex.handleevent(var event:tevent);
procedure tilewindows;
var r:trect;
begin
getextent(r);
r.grow(0,-1);
r.move(0,-1);
desktop^.tile(r)
end;
procedure cascadewindows;
var
r:trect;
begin
getextent(r);
r.grow(0,-1);
r.move(0,-1);
desktop^.cascade(r)
end;
begin
tapplication.handleevent(event);
if event.what=evcommand then
begin
case event.command of
cmopen:openwindow(notitle);
cmtile:tilewindows;
cmcascade:cascadewindows;
else exit
end;
clearevent(event);
end;
end;
procedure ex.idle;
function istileable(p:pview):boolean;far;
begin
istileable:=P^.options and oftileable <> 0
end;
begin
tapplication.idle;
if desktop^.firstthat(@istileable) <> nil
then enablecommands([cmtile,cmcascade])
else disablecommands([cmtile,cmcascade])
end;

procedure ex.initmenubar;
var r:trect;
begin
getextent(r);
r.b.y:=r.a.y+1;
menubar:=new(pmenubar,init(r,newmenu(newsubmenu('~F~ile',hcnocontext,
newmenu(newitem('~O~pen','F3',kbF3,cmopen,hcnocontext,
newline(newitem('E~x~it','Alt+X',kbAltx,cmquit,hcnocontext,nil)))),
newsubmenu('~W~indow',hcnocontext,newmenu(
newitem('~S~ize','Ctrl+F5',kbCtrlF5,cmresize,hcnocontext,
newitem('~Z~oom','F5',kbF5,cmzoom,hcnocontext,newline(
newitem('~T~itle','',kbnokey,cmtile,hcnocontext,
newitem('~c~ascade','',kbnokey,cmcascade,hcnocontext,newline(
newitem('~N~ext','F6',kbF6,cmNext,hcnocontext,
newitem('~P~revious','Shift+F6',kbShiftF6,cmprev,hcnocontext,
newitem('~C~lose','Alt+F3',kbAltF3,cmclose,hcnocontext,nil)))))))))),
newsubmenu('~O~ptiuni',hcnocontext,newmenu(
newitem('~C~ulori','Alt+C',kbAltC,cmculori,hcnocontext,newline(
newitem('~S~unet','Alt+S',kbAltS,cmsunet,hcnocontext,nil)))),nil))))))
end;
procedure ex.initstatusline;
var r:Trect;
begin
getextent(r);
r.a.y:=r.b.y-1;
statusline:=new(pstatusline,init(r,
newstatusdef(0,$FFFF,
newstatuskey('',kbF10,cmmenu,
newstatuskey('~Alt+X~-Exit',kbAltx,cmquit,
newstatuskey('~F3~-Open',kbF3,cmopen,
newstatuskey('~F5~-zoom',kbf5,cmzoom,
newstatuskey('~Alt+F3~-Close',kbaltf3,cmclose,
newstatuskey('~F6~-Next',kbf6,cmnext,nil)))))),nil)))
end;

procedure ex.openwindow(wtitle:string);
var w:Pfereastra;
begin
new(w,init(Wtitle));
desktop^.insert(W)
end;

constructor fereastra.init(wtitle:string);
var r:trect;
begin
desktop^.getextent(R);
r.assign(nrfereastra,nrfereastra,r.b.x,r.b.y);
inc(nrfereastra);
twindow.init(r,Wtitle,getwindownumber);
options:=options or oftileable;
if nrfereastra >= maxwindows then disablecommands([cmopen])
end;

procedure fereastra.close;
begin
twindow.close;
putwindowNumber;
dec(nrfereastra);
enablecommands([cmopen])
end;

function fereastra.getwindownumber:integer;
var i:integer;
begin
for i:=1 to maxwindows do
if not (i in winN) then
begin
getwindownumber:=i;
winn:=winn+[i];
exit
end;
getwindownumber:=wnnonumber
end;

procedure fereastra.putwindownumber;
begin
if (1<=number) and (number <=maxwindows)then winn:=winn-[number]
end;
var aplicatia:ex;
begin
aplicatia.init;
aplicatia.run;
aplicatia.done;
end.


^