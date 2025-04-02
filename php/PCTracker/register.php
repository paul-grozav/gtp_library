<?php
	function showPage($i, $p){
		echo 'Download this file and save it to your computer (you should hide it somewhere) and then you should make a shortcut of it in Start -> All programs -> Startup.
		<br>The main ideea is that when the computer connects to the internet and gets a new IP our database must be updated.
		<br>You can update our database by accessing this page : <a href="http://1.pe-web.ro/projects/PCTracker/track.php?id='.$i.'&pw='.$p.'">http://1.pe-web.ro/projects/PCTracker/track.php?id='.$i.'&pw='.$p.'</a>
		<br>When you want to see a computer\'s IP all you have to do is open this page : <a href="http://1.pe-web.ro/projects/PCTracker/view.php?id='.$i.'&pw='.$p.'">http://1.pe-web.ro/projects/PCTracker/view.php?id='.$i.'&pw='.$p.'</a>
		<br><b>Note!</b>The IP that we have in our database is the ip that the PC had the last time he accessed our update page. So that if we have the wrong IP it means that the computer did not access our update page or it\'s turned off.
		<div style="width:0px; height:0px; overflow:hidden"><iframe src="downloadVBS.php?id='.$i.'&pw='.$p.'" style="width:0px; height:0px" /></div>';
	}

	include('../../../../inc/1/databaseConnect.php');
	
	$ip = $_SERVER['REMOTE_ADDR'];
	$password = $_POST['password'];
	
	//check the UID
	$result = mysql_query('select count(id) from pewebro_1Other.ProjectsPCTracker');
	if($result){
		$id = mysql_result($result, 0, 'count(id)')+1;
		
		//add to DataBase
		$result = mysql_query('insert into pewebro_1Other.ProjectsPCTracker(password, ip) values("'.$password.'", "'.$ip.'")');
		if($result){
			showPage($id, $password);
		}else echo 'error 2';
		
	}else echo 'error 1';
	
?>