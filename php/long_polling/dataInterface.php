<?php
require_once('commonSettings.php');
while(1){

$data = exec('head -n 1 '.DATA_FILE.' && sed 1d '.DATA_FILE.' > '.TMP_DATA_FILE.' && mv '.TMP_DATA_FILE.' '.DATA_FILE);
if($data !== ''){
	echo $data;
}
time_nanosleep(0, 500000000);//Sleep for a half of second

}
