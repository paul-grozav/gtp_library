<?php
// Author: Tancredi-Paul Grozav <paul@grozav.info>
//
// Spre Arad:
// 11 - Mandruloc -> Fat frumos   = http://www.ctparad.ro/programe/tramvai/0011/0011t004.htm
// 12 - Mandruloc -> Piata Romana = http://www.ctparad.ro/programe/tramvai/0012/0012t004.htm
//
// De la Arad:
// 11 - Mandruloc -> Ghioroc      = http://www.ctparad.ro/programe/tramvai/0011/0011t040.htm
// 12 - Mandruloc -> Ghioroc      = http://www.ctparad.ro/programe/tramvai/0012/0012t034.htm
// ==================================================== //
//$link = 'http://www.ctparad.ro/programe/tramvai/0011/0011t004.htm';

//$data = simplexml_load_string($data) or die("Error: Cannot create object");

$lines = array(
  'http://www.ctparad.ro/programe/tramvai/0011/0011t004.htm',
  'http://www.ctparad.ro/programe/tramvai/0012/0012t004.htm',
  'http://www.ctparad.ro/programe/tramvai/0011/0011t040.htm',
  'http://www.ctparad.ro/programe/tramvai/0012/0012t034.htm',
);
foreach($lines as $line){
  $data = file_get_contents($line);
  $d = new DOMDocument();
  $d->loadHTML($data);
  $node = $d->childNodes[1]->childNodes[1]->childNodes[1]->childNodes[0]->childNodes[1]->childNodes[0];
  $data = $node->ownerDocument->saveHTML($node);
  print($data);
}

/*
$data = $d
  ->childNodes[1]// html
  ->childNodes[1]// body
  ->childNodes[1]// table
  ->childNodes[0]// tr
  ->childNodes[1]// td
  ->childNodes[0]// table
  ->childNodes[2]// tr
//  ->childNodes[0]// td ( hours )
;
$hi=-1;
foreach($data->childNodes as $hour){
  $hi++;
  $minutes = $data->parentNode->childNodes[3]->childNodes[$hi];
//  var_dump($minutes);
  print($hour->textContent.':'.$minutes->textContent."\n");
}
*/

//var_dump($data);
//print_r($data);
