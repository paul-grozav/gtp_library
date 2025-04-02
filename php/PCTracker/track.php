<?php
if(isset($_GET['id']) && isset($_GET['pw'])){
	include('../../../../inc/1/databaseConnect.php');
	$result = mysql_query('update pewebro_1Other.ProjectsPCTracker set ip="'.$_SERVER['REMOTE_ADDR'].'" where id='.$_GET['id'].' and password="'.$_GET['pw'].'"');
}
?>
<script type="text/javascript">window.close();</script>