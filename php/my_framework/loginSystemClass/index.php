<?php

	require_once('LoginSystem.php');
	
	$d->email = 'fluturel@gmail.com';
	$d->password = '12345678910';
	
	$a = new LoginSystem();
//	print $a->createAnAccount($d);
//	LoginSystem::activateAccount();
	print $a->logIn($d);

?>