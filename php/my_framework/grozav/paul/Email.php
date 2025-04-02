<?php
class Email{
	private $nl;

	private $to;
	private $subject;
	private $headers;
	private $sep1;
	private $sep2;
	private $plainText;
	private $htmlText;
	private $filesAttached;

	/**
	$to can be "Jimmy Olsen <jimmyo@gmail.com>" but also "jimmyo@gmail.com"
	**/
	public function  __construct($to, $subject, $from = 'webmaster@trambita.ro'){
		$this->nl = "\r\n";
	
		$this->to = $to;
		$this->subject = $subject;
		$this->sep1 = md5(uniqid(rand()));
		$this->sep2 = md5(uniqid(rand()));
		
		$this->headers = 'From: '.$from."\r\n";
		$this->headers .= 'MIME-Version: 1.0'."\r\n";
		$this->headers .= 'Content-Type: multipart/related; boundary='.$this->sep1."\r\n";
		
		$this->filesAttached = array();
	}
	
	public function setPlainText($value){
		$this->plainText = $value;
	}
	
	public function setHTMLText($value){
		$this->htmlText = $value;
	}
	
	public function attachFile($filePath){
		array_push($this->filesAttached, $filePath);
		return count($this->filesAttached).'@localhost.localdomain';
	}
	
	private function filesAttached(){
		$index = 0;
		$body = '';
		foreach($this->filesAttached as $file){
			$index++;
			$body .= '--'.$this->sep1.$this->nl;
//			$body .= 'Content-Type: '.mime_content_type($file).$this->nl;
			$body .= 'Content-Type: '.exec('file -i -b '.$file).$this->nl;
			$body .= 'Content-Transfer-Encoding: base64'.$this->nl;
			$body .= 'X-Attachment-Id: '.$index.'@localhost.localdomain'.$this->nl;
			$body .= 'Content-ID: <'.$index.'@localhost.localdomain>'.$this->nl;
			$body .= $this->nl;
			$body .= base64_encode(file_get_contents($file));
			$body .= $this->nl;
		}
		return $body;
	}
	
	public function send(){
		$body = '--'.$this->sep1.$this->nl;
			$body .= 'Content-Type: multipart/alternative; boundary='.$this->sep2.$this->nl;
			$body .= '--'.$this->sep2.$this->nl;
			$body .= 'Content-Type: text/plain; charset=ISO-8859-1'.$this->nl;
			$body .= $this->nl;
			$body .= $this->plainText.$this->nl;
			$body .= '--'.$this->sep2.$this->nl;
			$body .= 'Content-Type: text/html; charset=ISO-8859-1'.$this->nl;
			$body .= $this->nl;
			$body .= $this->htmlText.$this->nl;
			$body .= $this->nl;
			$body .= '--'.$this->sep2.'--'.$this->nl;
		$body .= $this->filesAttached();
		$body .= '--'.$this->sep1.'--'.$this->nl;
		
		return mail($this->to, $this->subject, $body, $this->headers);
	}
	
	public function __toString(){
		return "";
	}
}
?>