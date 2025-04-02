<?php
class ConstantWidthPage {
	public $width;
	public $border;
	private $elements;

    public function  __construct(){
		$this->elements = array();
		
		$this->width = '800px';
		$this->border = '1px solid gray';
    }

    public function  __toString() {
		global $_HTML_DOCUMENT;

		$_HTML_DOCUMENT->addStyleCode('
			.pageContainer{
				width: '.$this->width.';
				margin-left:auto; margin-right:auto;'./* Center page container */'
				border: '.$this->border.';
			}
		');

		$code = '<div class="pageContainer">';
		for($i=0; $i<count($this->elements); $i++)
			$code .= $this->elements[$i];
		$code .= '</div>';
		return $code;
    }

    public function addElement($object){
		array_push($this->elements, $object);
	}
}
?>
