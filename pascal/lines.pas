{Getmxcol.PAS}

{Sample code for the GetMaxColor, SetColor functions.}

uses
 Crt, Graph;
var
 GraphDriver, GraphMode : Integer;
 a:longint;
begin
 GraphDriver := Detect;
 InitGraph(GraphDriver, GraphMode, '.\graph');
 if GraphResult <> grOk then Halt(1);
 Randomize;
 repeat
   for a:=1 to 999999 do begin end;
   SetColor(Random(GetMaxColor)+1);
   LineTo(Random(GetMaxX),
          Random(GetMaxY));
 until KeyPressed;
end.




