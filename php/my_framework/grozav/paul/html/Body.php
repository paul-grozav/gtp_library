<?php
class Body{
    private $parent;
    private $attributes;
    private $elements;

    public function  __construct($parent) {
        $this->parent = $parent;
        $this->attributes = array();
        $this->elements = array();
    }

    public function addElement($object){
        array_push($this->elements, $object);
    }

    public function setAttribute($name, $value){
        $attr['name'] = $name;
        $attr['value'] = $value;
        array_push($this->attributes, $attr);
    }

    public function getAttribute($name){
        for($i=0; $i<count($this->attributes); $i++)
            if($this->attributes[$i]['name'] == $name)
                return $this->attributes[$i]['value'];
    }

    public function __toString(){
        $code = '<body';
            for($i=0; $i<count($this->attributes); $i++)
                $code .= ' '.$this->attributes[$i]['name'].'="'.$this->attributes[$i]['value'].'"';
        $code .= '>';

		for($i=0; $i<count($this->elements); $i++)
			$code .= $this->elements[$i];
		
        $code .= '</body>';
        return $code;
    }
}
?>