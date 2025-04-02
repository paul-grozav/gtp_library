<?php
session_start();

require_once('LoginSystem.config.php');

class LoginSystem{

	/**
		Legend:
			1 = There is another account with the same email
			2 = One of the parameters is not string and is not an object
			3 = One of the parameters is an object but it doesn't have the 'value' property
			4 = Error while adding the new user to database
			5 = One of the parameters is an object and it's value isn't accepted
			6 = One property name is not alphabetic. it contains spaces or numbers or any other characters
			7 = Could not add session_id() to verification codes table for the new user
			8 = Could not get userid and code generation time from verification codes for the new user
			9 = The email could not be sent
			10 = SUCCESS !!!
			11 = Error while checking if there is any other user with the same email
	*/
	public function createAnAccount($params){
		//verific daca mai este un utilizator cu acelasi email
		$result = mysql_query('select count('.LOGIN_SYSTEM_USERS_TABLE_EMAIL_COLUMN_NAME.') from '.LOGIN_SYSTEM_DATA_BASE_NAME.'.'.LOGIN_SYSTEM_USERS_TABLE_NAME.' where '.LOGIN_SYSTEM_USERS_TABLE_EMAIL_COLUMN_NAME.'="'.addslashes(eval('return $params->'.LOGIN_SYSTEM_USERS_TABLE_EMAIL_COLUMN_NAME.';')).'";');
		if($result === FALSE) return 11;
		if(mysql_result($result, 0, 'count('.LOGIN_SYSTEM_USERS_TABLE_EMAIL_COLUMN_NAME.')') != 0) return 1;
		
		//adaug utilizatorul
		$query = 'insert into '.LOGIN_SYSTEM_DATA_BASE_NAME.'.'.LOGIN_SYSTEM_USERS_TABLE_NAME.'(';
		
		//pun proprietatile in lista
		foreach($params as $property => $value){
			if(ctype_alpha($property) === TRUE){//if it only contains letters (no spaces, no numbers, no underscore...
				$query .= $property.',';
			}else{
				return 6;
			}
		}
		
		$query = substr($query, 0, strlen($query)-1);
		$query .= ')value(';

		//pun valorile
		foreach($params as $property => $value){
			if(is_string($value)){//normal value
				$query .= '"'.addslashes($value).'",';
			}else{//trebe sa fie de forma {value : 'value'}
				if(is_object($value)){
					if(property_exists($value, 'value')){
						if(is_numeric($value->value) === TRUE){
							$query .= $value->value.',';//daca e numerica valoare o pun direct
						}else{
							switch($value->value){//daca nu ... poate e una din chestiile definite
								case 'NOW()':
									$query .= 'NOW(),';
									break;
								default: return 5; break;
							}
						}
					}else{
						return 3;
					}
				}else{
					return 2;
				}
			}
		}
		
		$query = substr($query, 0, strlen($query)-1);
		$query .= ');';
		
		if(mysql_query($query) === FALSE) return 4;

		//Adaugam in tabelul recuperare parola utilizatorul pentru a-si confirma contul
		if(mysql_query('insert into '.LOGIN_SYSTEM_DATA_BASE_NAME.'.'.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_NAME.'('.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_CODE_COLUMN_NAME.', '.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_USER_COLUMN_NAME.')value("'.session_id().'", LAST_INSERT_ID());') === FALSE) return 7;

		//aflu idUtilizator si ct pentru intrarea in recuperareParola .. si le trimit pe mail 
		$result = mysql_query('select '.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_USER_COLUMN_NAME.', '.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_TIME_COLUMN_NAME.' from '.LOGIN_SYSTEM_DATA_BASE_NAME.'.'.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_NAME.' where '.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_ID_COLUMN_NAME.'=LAST_INSERT_ID();');
		if($result === FALSE) return 8;

		//trimit mailul
		if(mail(eval('return $params->'.LOGIN_SYSTEM_USERS_TABLE_EMAIL_COLUMN_NAME.';'), LOGIN_SYSTEM_CREATE_AN_ACCOUNT_MAIL_SUBJECT, str_replace('VERIFICATION_CODE', sha1(session_id()).sha1(mysql_result($result, 0, LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_USER_COLUMN_NAME)).sha1(mysql_result($result, 0, LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_TIME_COLUMN_NAME)),LOGIN_SYSTEM_CREATE_AN_ACCOUNT_MAIL_BODY), "MIME-Version: 1.0\r\nContent-type: text/html; charset=iso-8859-1\r\nFrom:".LOGIN_SYSTEM_CREATE_AN_ACCOUNT_MAIL_FROM."\r\n", '-f '.LOGIN_SYSTEM_CREATE_AN_ACCOUNT_MAIL_FROM) === TRUE){
			return 10;
		}else{
			return 9;
		}
	}
	
	public static function activateAccount(){
		//caut id-ul utilizatorului ce are codurile astea	
		$result = mysql_query('select '.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_ID_COLUMN_NAME.','.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_USER_COLUMN_NAME.' from '.LOGIN_SYSTEM_DATA_BASE_NAME.'.'.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_NAME.' where CONCAT(SHA1('.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_CODE_COLUMN_NAME.'),SHA1('.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_USER_COLUMN_NAME.'),SHA1('.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_TIME_COLUMN_NAME.'))="'.addslashes($_GET['c']).'" and NOW() < ('.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_TIME_COLUMN_NAME.' + INTERVAL '.LOGIN_SYSTEM_ACTIVATE_ACCOUNT_TIME_TO_ACTIVATE_IN_HOURS.' HOUR);');
		if(($result === FALSE) || (mysql_num_rows($result) !== 1)) die(LOGIN_SYSTEM_ACTIVATE_ACCOUNT_WRONG_OR_EXPIRED_CODE_MESSAGE);

		$idUtilizator = mysql_result($result, 0, LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_USER_COLUMN_NAME);
		$idInregistrareRecuperareParola = mysql_result($result, 0, LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_ID_COLUMN_NAME);
		
		//trec utilizatorul pe activ
		if(mysql_query('update '.LOGIN_SYSTEM_DATA_BASE_NAME.'.'.LOGIN_SYSTEM_USERS_TABLE_NAME.' set '.LOGIN_SYSTEM_USERS_TABLE_STATE_COLUMN_NAME.'="'.LOGIN_SYSTEM_USERS_TABLE_STATE_COLUMN_ACTIVE_STATE.'" where '.LOGIN_SYSTEM_USERS_TABLE_ID_COLUMN_NAME.'='.$idUtilizator.';') === FALSE)
			die(LOGIN_SYSTEM_ACTIVATE_ACCOUNT_COULD_NOT_ACTIVATE_USER_MESSAGE);
		
		//sterg inregistrarea din tabelul recuperareParola
		$result = mysql_query('delete from '.LOGIN_SYSTEM_DATA_BASE_NAME.'.'.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_NAME.' where '.LOGIN_SYSTEM_VERIFICATION_CODES_TABLE_ID_COLUMN_NAME.'='.$idInregistrareRecuperareParola.';');
		die(LOGIN_SYSTEM_ACTIVATE_ACCOUNT_ACCOUNT_ACTIVATED_MESSAGE);
	}
	
	/**
		Legend:
			1 = LOGGED IN !!!
			2 = Invalid username or password
	*/
	public function logIn($params){
		$result = mysql_query('select '.LOGIN_SYSTEM_LOG_IN_COLUMNS_TO_SELECT.' from '.LOGIN_SYSTEM_DATA_BASE_NAME.'.'.LOGIN_SYSTEM_USERS_TABLE_NAME.' where '.LOGIN_SYSTEM_USERS_TABLE_EMAIL_COLUMN_NAME.'="'.addslashes(eval('return $params->'.LOGIN_SYSTEM_USERS_TABLE_EMAIL_COLUMN_NAME.';')).'" and '.LOGIN_SYSTEM_USERS_TABLE_PASSWORD_COLUMN_NAME.'="'.addslashes(eval('return $params->'.LOGIN_SYSTEM_USERS_TABLE_PASSWORD_COLUMN_NAME.';')).'";');
		
		if(LOGIN_SYSTEM_LOG_IN_RETURN_USER_DATA=== FALSE){
			if(($result !== FALSE) && (mysql_num_rows($result) === 1)){
				$_SESSION[LOGIN_SYSTEM_LOG_IN_SESSION_DIMENSION_NAME]->connected = TRUE;
				return 1;
			}else return 2;
		}else{
			$r->accepted = FALSE;
			if(($result !== FALSE) && (mysql_num_rows($result) === 1)){
				$_SESSION[LOGIN_SYSTEM_LOG_IN_SESSION_DIMENSION_NAME]->data = mysql_fetch_object($result);
				$_SESSION[LOGIN_SYSTEM_LOG_IN_SESSION_DIMENSION_NAME]->connected = TRUE;
				$r->accepted = TRUE;
				return 1;
			}else return 2;
		}
	}

}

?>