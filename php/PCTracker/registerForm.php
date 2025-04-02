<html>
	<head>
		<title>PC Tracker</title>
	</head>
	<body>
	<script type="text/javascript">
		function register(){
			if((document.getElementById("password").value != "") || confirm("Are you sure you don't want to set a password?"))
				form.submit();
		}
	</script>
	<form id="form" method="POST" action="register.php">
		<table bgcolor="#dadada" width="275px" align="center">
			<tr><td colspan="2" align="center"><font style="font-size:27px">Your IP is: <input type="text" value="<?php echo $_SERVER['REMOTE_ADDR']; ?>" disabled></font></td></tr>
			<tr>
				<td width="119px">Password :</td>
				<td><input type="password" name="password" id="password"></td>
			</tr>
			<tr><td colspan="2" align="center"><input type="button" value="register" onClick="register()"></td></tr>
		</table>
	</form>
	- <b>Password</b> (<i>Optional</i> - but recommended) <font color="#ff0000">Low security!</font> The password will be stored on the computer that you track. Anyone using that computer could see it (if they find it). You need this password to change the current IP of this PC.
	</body>
</html>