<?php
require_once('commonSettings.php');
file_put_contents(DATA_FILE, $_POST['data'], FILE_APPEND);

