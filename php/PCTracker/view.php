<?php
if(isset($_GET['id']) && isset($_GET['pw'])){
	include('../../../../inc/1/databaseConnect.php');
	$result = mysql_query('select ip from pewebro_1Other.ProjectsPCTracker where id='.$_GET['id'].' and password="'.$_GET['pw'].'"');
	if($result){
		if(mysql_num_rows($result) == 1){
			echo mysql_result($result, 0, 'ip');
		}else echo 'wrong id & password combination';
	}else echo 'error 1';
}else{
	echo '<script type="text/javascript">function show(){
	var id = document.getElementById("id").value;
	var pw = document.getElementById("pw").value;
	window.location = "view.php?id="+id+"&pw="+pw;
	}</script>
	<div id="goto">
	ID:<input type="text" id="id"/>
	<br>Password:<input type="password" id="pw"/>
	<br><input type="button" value="Show !" onclick="show()"/>
	</div>';
}
?>