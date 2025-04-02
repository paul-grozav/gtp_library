<?php
require_once('Body.php');

class HTMLDocument{
    /** The title of the page **/
    public $title;
    private $style;
    public $body;
    public $headContent;

    public function  __construct(){
        global $_HTML_DOCUMENT;
        $_HTML_DOCUMENT = $this;

        $this->headContent = '';
        $this->body = new Body($this);
    }

    /** Converts the HTMLPage to a (one line) string **/
    public function  __toString() {
		$body = ''.$this->body;//generate the Body => generate the styles for the body
        $code = '<!DOCTYPE html>
			<html>
				<head>';

                    if(isset($this->title))
                        $code .= '<title>'.$this->title.'</title>';

                    if(isset($this->style))
                        $code .= '<style>'.$this->style.'</style>';

        $code .= $this->headContent.'
				</head>
				'.$body/*The generated body*/.'
			</html>';
        $code = ereg_replace("\n\r|\r\n|\t|\n|\r", '', $code);
        return $code;
    }

    public function writeToHead($string){
        if(isset($this->headContent))
            $this->headContent .= $string;
        else
            $this->headContent = $string;
    }

    public function addStyleSheet($pathToCSSFile){
        $this->writeToHead('<link rel="stylesheet" href="'.$pathToCSSFile.'" type="text/css" media="screen"/>');
    }

	public function addStyleCode($CSSCode){
		if(isset($this->style))
			$this->style .= $CSSCode;
		else
			$this->style = $CSSCode;
	}

}
?>