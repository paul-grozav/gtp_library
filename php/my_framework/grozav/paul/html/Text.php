<?php
require_once('Body.php');

class Text{
	public $text;

    public function  __construct($text){
        $this->text = $text;
    }

    public function  __toString() {
	    return $this->text;
    }
	
}
?>