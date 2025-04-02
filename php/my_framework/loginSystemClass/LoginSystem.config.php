<?php

	// You should already be connected to MySQL
	mysql_connect('localhost', 'partner4_invmate', 'SECRET_PASSWORD') or die ('could not connect to MySQL');

	define('LOGIN_SYSTEM_DATA_BASE_NAME', 'partner4_invatamatero');

	//USERS TABLE
	define('LOGIN_SYSTEM_USERS_TABLE_NAME', 'utilizatori');
	define('LOGIN_SYSTEM_USERS_TABLE_EMAIL_COLUMN_NAME', 'email');
	define('LOGIN_SYSTEM_USERS_TABLE_PASSWORD_COLUMN_NAME', 'password');
	define('LOGIN_SYSTEM_USERS_TABLE_STATE_COLUMN_NAME', 'stare');
	define('LOGIN_SYSTEM_USERS_TABLE_STATE_COLUMN_ACTIVE_STATE', 'activ');
	define('LOGIN_SYSTEM_USERS_TABLE_ID_COLUMN_NAME', 'id');

	//VERIFICATION CODES TABLE
	define('LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_NAME', 'recuperareParola');
	define('LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_ID_COLUMN_NAME', 'id');
	define('LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_CODE_COLUMN_NAME', 'cod');
	define('LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_USER_COLUMN_NAME', 'utilizator');//id of the user that has this code
	define('LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_TIME_COLUMN_NAME', 'ct');//time when the code was generated

	//CREATE AN ACCOUNT
	define('LOGIN_SYSTEM_CREATE_AN_ACCOUNT_MAIL_SUBJECT', 'Activare cont invatamate.ro');
	define('LOGIN_SYSTEM_CREATE_AN_ACCOUNT_MAIL_BODY', 'Contul dumneavoastra trebuie activat in maxim 24 de ore de la creare, in caz contrar va rugam sa ne contactati telefonic.<br/>Pentru activarea contului apasati <a href="http://1.pe-web.ro/dev/html/php/loginSystemClass/index.php?c=VERIFICATION_CODE" target="_blank">aici</a>');//(sub)string 'VERIFICATION_CODE' will be replaced with the proper verification code
	define('LOGIN_SYSTEM_CREATE_AN_ACCOUNT_MAIL_FROM', 'webmaster@invatamate.ro');

	//ACTIVATE ACCOUNT
	define('LOGIN_SYSTEM_ACTIVATE_ACCOUNT_TIME_TO_ACTIVATE_IN_HOURS', 24);
	define('LOGIN_SYSTEM_ACTIVATE_ACCOUNT_WRONG_OR_EXPIRED_CODE_MESSAGE', 'Codul dumneavoastra a expirat sau este incorect!');
	define('LOGIN_SYSTEM_ACTIVATE_ACCOUNT_COULD_NOT_ACTIVATE_USER_MESSAGE', 'Activarea a esuat!');
	define('LOGIN_SYSTEM_ACTIVATE_ACCOUNT_ACCOUNT_ACTIVATED_MESSAGE', 'Puteti sa va conectati! Contul dumneavoastra este activ!');

	//SIGN IN
	define('LOGIN_SYSTEM_LOG_IN_COLUMNS_TO_SELECT', '*');//what columns should be selected for the user
	define('LOGIN_SYSTEM_LOG_IN_SESSION_DIMENSION_NAME', 'user');
	define('LOGIN_SYSTEM_LOG_IN_RETURN_USER_DATA', TRUE);

?>
