<?php
if(isset($_GET['id']) && isset($_GET['pw'])){
header('Content-type: text/vbscript');
header('Content-Disposition: attachment; filename="startUp.vbs"');
echo 'Function Ping(Target)
Dim results
    On Error Resume Next
    Set shell = CreateObject("WScript.Shell")
    Set exec = shell.Exec("ping -n 1 -w 2000 " & Target)
    results = LCase(exec.StdOut.ReadAll)
    Ping = (InStr(results, "reply from") > 0)
End Function

Do While NOT Ping("1.pe-web.ro")
Loop

set Window = CreateObject("InternetExplorer.Application")

Window.RegisterAsBrowser = True
Window.Navigate("http://1.pe-web.ro/projects/PCTracker/track.php?id='.$_GET['id'].'&pw='.$_GET['pw'].'")
Window.Visible = true';
}else echo 'error 1';
?>