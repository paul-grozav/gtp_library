{Rectangl.PAS}

{Sample code for the Rectangle procedure.}

uses Crt, Graph;

var
 GraphDriver, GraphMode: Integer;
X1, Y1, X2, Y2: Integer;
stai:longint;
begin
 GraphDriver := Detect;
 InitGraph(GraphDriver, GraphMode, '.\graph');
 if GraphResult<> grOk then
   Halt(1);
 Randomize;
 repeat
for stai:=01 to 9999999 do begin end;
 setcolor(random(9999));
   X1 := Random(GetMaxX);
   Y1 := Random(GetMaxY);
   X2 := Random(GetMaxX - X1) + X1;
   Y2 := Random(GetMaxY - Y1) + Y1;
   Rectangle(X1, Y1, X2, Y2);
 until KeyPressed;
 CloseGraph;
end.



