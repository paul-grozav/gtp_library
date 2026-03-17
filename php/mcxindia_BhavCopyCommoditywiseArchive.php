#!/usr/bin/php5
<?php
/*
Author: Tancredi-Paul Grozav (paul@grozav.info)
This script should help download data from mcxindia

Did you ever want to get data from
http://www.mcxindia.com/SitePages/BhavCopyCommoditywiseArchive.aspx ? I did! And
I made this code to help you all. The script downloads all CSV files from that
URL and saves them to the local disk. To do that it takes about 3.5 hours (on my
PC). You must have a folder named output in the current directory, then the
script will create there a folder where it will put all the .CSV files.
*/
define('SPEAK', true);
define('WEB_APP_URL', 'http://www.mcxindia.com/SitePages/BhavCopyCommoditywiseArchive.aspx');
define('OUTPUT_FILE_PATH', 'output/' . date('YmdHis')); //Whenever you run the script, it creates a folder containing all the files
mkdir(OUTPUT_FILE_PATH); //create the folder to hold all files

// ! Check for requirements

if (!in_array('curl', get_loaded_extensions())) die("n" . 'CURL is not installed. Fatal error: Can not check for weather image');

// Utils functions

function gzdecode($data, &$filename = '', &$error = '', $maxlength = null)
    {
    $len = strlen($data);
    if ($len < 18 || strcmp(substr($data, 0, 2) , "x1fx8b"))
        {
        $error = "Not in GZIP format.";
        return null; // Not GZIP format (See RFC 1952)
        }

    $method = ord(substr($data, 2, 1)); // Compression method
    $flags = ord(substr($data, 3, 1)); // Flags
    if ($flags & 31 != $flags)
        {
        $error = "Reserved bits not allowed.";
        return null;
        }

    // NOTE: $mtime may be negative (PHP integer limitations)

    $mtime = unpack("V", substr($data, 4, 4));
    $mtime = $mtime[1];
    $xfl = substr($data, 8, 1);
    $os = substr($data, 8, 1);
    $headerlen = 10;
    $extralen = 0;
    $extra = "";
    if ($flags & 4)
        {

        // 2-byte length prefixed EXTRA data in header

        if ($len - $headerlen - 2 < 8)
            {
            return false; // invalid
            }

        $extralen = unpack("v", substr($data, 8, 2));
        $extralen = $extralen[1];
        if ($len - $headerlen - 2 - $extralen < 8)
            {
            return false; // invalid
            }

        $extra = substr($data, 10, $extralen);
        $headerlen+= 2 + $extralen;
        }

    $filenamelen = 0;
    $filename = "";
    if ($flags & 8)
        {

        // C-style string

        if ($len - $headerlen - 1 < 8)
            {
            return false; // invalid
            }

        $filenamelen = strpos(substr($data, $headerlen) , chr(0));
        if ($filenamelen === false || $len - $headerlen - $filenamelen - 1 < 8)
            {
            return false; // invalid
            }

        $filename = substr($data, $headerlen, $filenamelen);
        $headerlen+= $filenamelen + 1;
        }

    $commentlen = 0;
    $comment = "";
    if ($flags & 16)
        {

        // C-style string COMMENT data in header

        if ($len - $headerlen - 1 < 8)
            {
            return false; // invalid
            }

        $commentlen = strpos(substr($data, $headerlen) , chr(0));
        if ($commentlen === false || $len - $headerlen - $commentlen - 1 < 8)
            {
            return false; // Invalid header format
            }

        $comment = substr($data, $headerlen, $commentlen);
        $headerlen+= $commentlen + 1;
        }

    $headercrc = "";
    if ($flags & 2)
        {

        // 2-bytes (lowest order) of CRC32 on header present

        if ($len - $headerlen - 2 < 8)
            {
            return false; // invalid
            }

        $calccrc = crc32(substr($data, 0, $headerlen)) & 0xffff;
        $headercrc = unpack("v", substr($data, $headerlen, 2));
        $headercrc = $headercrc[1];
        if ($headercrc != $calccrc)
            {
            $error = "Header checksum failed.";
            return false; // Bad header CRC
            }

        $headerlen+= 2;
        }

    // GZIP FOOTER

    $datacrc = unpack("V", substr($data, -8, 4));
    $datacrc = sprintf('%u', $datacrc[1] & 0xFFFFFFFF);
    $isize = unpack("V", substr($data, -4));
    $isize = $isize[1];

    // decompression:

    $bodylen = $len - $headerlen - 8;
    if ($bodylen < 1)
        {

        // IMPLEMENTATION BUG!

        return null;
        }

    $body = substr($data, $headerlen, $bodylen);
    $data = "";
    if ($bodylen > 0)
        {
        switch ($method)
            {
        case 8:

            // Currently the only supported compression method:

            $data = gzinflate($body, $maxlength);
            break;

        default:
            $error = "Unknown compression method.";
            return false;
            }
        } // zero-byte body content is allowed

    // Verifiy CRC32

    $crc = sprintf("%u", crc32($data));
    $crcOK = $crc == $datacrc;
    $lenOK = $isize == strlen($data);
    if (!$lenOK || !$crcOK)
        {
        $error = ($lenOK ? '' : 'Length check FAILED. ') . ($crcOK ? '' : 'Checksum FAILED.');
        return false;
        }

    return $data;
    }

function string_get_before($string, $before)
    {
    return substr($string, 0, strpos($string, $before));
    }

function string_get_after($string, $after)
    {
    $pos = strpos($string, $after) + strlen($after);
    return substr($string, $pos, strlen($string) - $pos);
    }

function string_starts_with($haystack, $needle)
    {
    return !strncmp($haystack, $needle, strlen($needle));
    }

function toPostParameters($pp)
    {
    for ($i = 0; $i < count($pp); $i++)
    foreach($pp[$i] as $key => $value) $pp[$i] = $key . '=' . $value;
    $pp = implode('&', $pp);
    return $pp;
    }

function getPage($header = NULL, $post = '')
    {
    $curlObject = curl_init();
    curl_setopt($curlObject, CURLOPT_URL, WEB_APP_URL);
    curl_setopt($curlObject, CURLOPT_RETURNTRANSFER, 1);
    if ($post !== '')
        {
        curl_setopt($curlObject, CURLOPT_POST, 1);
        curl_setopt($curlObject, CURLOPT_POSTFIELDS, $post);

        // print('POST:'.$post);

        }

    curl_setopt($curlObject, CURLOPT_VERBOSE, true);
    curl_setopt($curlObject, CURLOPT_HEADER, true);
    curl_setopt($curlObject, CURLINFO_HEADER_OUT, true);
    if (!is_null($header)) curl_setopt($curlObject, CURLOPT_HTTPHEADER, $header);
    $r['requestHeader'] = '';
    $r['responseHeader'] = '';
    $r['response'] = curl_exec($curlObject);
    $r['responseHeader'] = substr($r['response'], 0, curl_getinfo($curlObject, CURLINFO_HEADER_SIZE));
    $r['response'] = substr($r['response'], curl_getinfo($curlObject, CURLINFO_HEADER_SIZE));
    $r['requestHeader'] = curl_getinfo($curlObject, CURLINFO_HEADER_OUT);
    return $r;
    }

function saveEventValidationAndViewState($r)
    {
    global $prevRequest;
    $prevRequest['eventValidation'] = rawurlencode(valueExtractor2($r['response'], '__EVENTVALIDATION'));
    $prevRequest['viewState'] = rawurlencode(valueExtractor2($r['response'], '__VIEWSTATE'));
    $prevRequest['cookie'] = implode('; ', getCookieValues($r['responseHeader']));
    $prevRequest['firstExpiryDate'] = getSelectOptionValuesAsArray(string_get_before(string_get_after($r['response'], '<select name="mDdlExpDate" id="mDdlExpDate" class="dd" style="text-transform: uppercase">') , "rnrn"));
    $prevRequest['firstExpiryDate'] = rawurlencode($prevRequest['firstExpiryDate'][0]);
    }

function valueExtractor($from, $tag)
    {
    $r = string_get_after($from, 'id="' . $tag . '" value="');
    $r = string_get_before($r, '" />');
    return $r;
    }

function valueExtractor2($tags, $tag)
    {
    $tags = explode('|', $tags);
    for ($i = 0; $i < count($tags); $i++)
    if ($tags[$i] === $tag) return $tags[$i + 1];
    }

function getCookieValues($headers)
    {
    $headers = explode("n", $headers);
    $r = array();

    // ! For all headers

    foreach($headers as $key => $header)
        {

        // ! If it's a 'Set-Cookie'

        if (string_starts_with($header, 'Set-Cookie: '))
            {

            // ! Set cookie values

            $cookieValues = substr($header, strlen('Set-Cookie: '));
            $cookieValues = explode('; ', $cookieValues);
            array_push($r, $cookieValues[0]);
            }
        }

    return $r;
    }

// downloads and saves the CSV file

function getCSVForSymbolAndDate($symbol, $expiryDate)
    {
    global $prevRequest;
    if (SPEAK) echo 'Getting ' . $symbol . ' for ' . $expiryDate . ' ...';

    // Third request - Clicking OK to get the values in HTML format

    $headers = array();
    array_push($headers, 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
    array_push($headers, 'Accept-Encoding: gzip, deflate');
    array_push($headers, 'Accept-Language: en-US,en;q=0.5');
    array_push($headers, 'Cache-Control: no-cache');
    array_push($headers, 'Connection: keep-alive');
    array_push($headers, 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8');
    array_push($headers, 'Cookie: __utma=169759165.1477622451.1368783172.1368783172.1368783172.1; __utmb=169759165.1.10.1368783172; __utmc=169759165; __utmz=169759165.1368783172.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); ' . $prevRequest['cookie'] . '');
    array_push($headers, 'DNT: 1');
    array_push($headers, 'Host: www.mcxindia.com');
    array_push($headers, 'Pragma: no-cache');
    array_push($headers, 'Referer: http://www.mcxindia.com/SitePages/BhavCopyCommoditywiseArchive.aspx');
    array_push($headers, 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:21.0) Gecko/20100101 Firefox/21.0');
    array_push($headers, 'X-MicrosoftAjax: Delta=true');
    $pp = array();
    array_push($pp, array(
        'ScriptManager1' => 'MupdPnl|mBtnGo'
    ));
    array_push($pp, array(
        '__EVENTARGUMENT' => ''
    ));
    array_push($pp, array(
        '__EVENTTARGET' => ''
    ));
    array_push($pp, array(
        '__EVENTVALIDATION' => $prevRequest['eventValidation']
    ));
    array_push($pp, array(
        '__LASTFOCUS' => ''
    ));
    array_push($pp, array(
        '__VIEWSTATE' => $prevRequest['viewState']
    ));
    array_push($pp, array(
        'mBtnGo.x' => '9'
    ));
    array_push($pp, array(
        'mBtnGo.y' => '14'
    ));
    array_push($pp, array(
        'mChkAll' => 'on'
    ));
    array_push($pp, array(
        'mDdlExpDate' => rawurlencode($expiryDate)
    ));
    array_push($pp, array(
        'mDdlSymbol' => $symbol
    ));
    array_push($pp, array(
        'mTbFromDate' => ''
    ));
    array_push($pp, array(
        'mTbToDate' => ''
    ));
    $r = getPage($headers, toPostParameters($pp));
    $r['response'] = gzdecode($r['response']);

    // print_r($r);die();

    saveEventValidationAndViewState($r);

    // Fourth request - get the prices in CSV format

    $headers = array();
    array_push($headers, 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
    array_push($headers, 'Accept-Encoding: gzip, deflate');
    array_push($headers, 'Accept-Language: en-US,en;q=0.5');
    array_push($headers, 'Cache-Control: no-cache');
    array_push($headers, 'Connection: keep-alive');
    array_push($headers, 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8');
    array_push($headers, 'Cookie: __utma=169759165.1477622451.1368783172.1368783172.1368783172.1; __utmb=169759165.1.10.1368783172; __utmc=169759165; __utmz=169759165.1368783172.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); ' . $prevRequest['cookie'] . '');
    array_push($headers, 'DNT: 1');
    array_push($headers, 'Host: www.mcxindia.com');
    array_push($headers, 'Pragma: no-cache');
    array_push($headers, 'Referer: http://www.mcxindia.com/SitePages/BhavCopyCommoditywiseArchive.aspx');
    array_push($headers, 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:21.0) Gecko/20100101 Firefox/21.0');
    array_push($headers, 'X-MicrosoftAjax: Delta=true');
    $pp = array();
    array_push($pp, array(
        '__EVENTTARGET' => 'linkButton'
    ));
    array_push($pp, array(
        '__EVENTARGUMENT' => ''
    ));
    array_push($pp, array(
        '__LASTFOCUS' => ''
    ));
    array_push($pp, array(
        '__VIEWSTATE' => $prevRequest['viewState']
    ));
    array_push($pp, array(
        'mDdlSymbol' => $symbol
    ));
    array_push($pp, array(
        'mDdlExpDate' => rawurlencode($expiryDate)
    ));
    array_push($pp, array(
        'mChkAll' => 'on'
    ));
    array_push($pp, array(
        '__EVENTVALIDATION' => $prevRequest['eventValidation']
    ));
    $r = getPage($headers, toPostParameters($pp));

    // print_r($r);die(toPostParameters($pp));

    $CSVFile = $r['response'];
    file_put_contents(OUTPUT_FILE_PATH . '/' . $symbol . '_' . date('Ymd', strtotime($expiryDate)) , $CSVFile);

    // echo "n".$CSVFile;

    if (SPEAK) echo " DONEn";
    }

function getSelectOptionValuesAsArray($options)
    {
    $options = explode("rn", trim($options));
    foreach($options as & $o)
        {
        $o = string_get_after($o, 'value="');
        $o = string_get_before($o, '"');
        }

    return $options;
    }

function getExpiryDatesForSymbol($symbol)
    {
    global $prevRequest;

    // Second request - selecting the symbol - this responds with the expiryDates for that symbol

    $headers = array();
    array_push($headers, 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
    array_push($headers, 'Accept-Encoding: gzip, deflate');
    array_push($headers, 'Accept-Language: en-US,en;q=0.5');
    array_push($headers, 'Cache-Control: no-cache');
    array_push($headers, 'Connection: keep-alive');
    array_push($headers, 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8');
    array_push($headers, 'Cookie: __utma=169759165.1477622451.1368783172.1368783172.1368783172.1; __utmb=169759165.1.10.1368783172; __utmc=169759165; __utmz=169759165.1368783172.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); ' . $prevRequest['cookie'] . '');
    array_push($headers, 'DNT: 1');
    array_push($headers, 'Host: www.mcxindia.com');
    array_push($headers, 'Pragma: no-cache');
    array_push($headers, 'Referer: http://www.mcxindia.com/SitePages/BhavCopyCommoditywiseArchive.aspx');
    array_push($headers, 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:21.0) Gecko/20100101 Firefox/21.0');
    array_push($headers, 'X-MicrosoftAjax: Delta=true');
    $pp = array();
    array_push($pp, array(
        'ScriptManager1' => 'MupdPnl|mDdlSymbol'
    ));
    array_push($pp, array(
        '__EVENTARGUMENT' => ''
    ));
    array_push($pp, array(
        '__EVENTTARGET' => 'mDdlSymbol'
    ));
    array_push($pp, array(
        '__EVENTVALIDATION' => $prevRequest['eventValidation']
    ));
    array_push($pp, array(
        '__LASTFOCUS' => ''
    ));
    array_push($pp, array(
        '__VIEWSTATE' => $prevRequest['viewState']
    ));
    array_push($pp, array(
        'mDdlExpDate' => $prevRequest['firstExpiryDate']
    )); //first expiryDate from previous response
    array_push($pp, array(
        'mDdlSymbol' => $symbol
    ));
    array_push($pp, array(
        'mTbFromDate' => ''
    ));
    array_push($pp, array(
        'mTbToDate' => ''
    ));
    $r = getPage($headers, toPostParameters($pp));
    $r['response'] = gzdecode($r['response']);
    saveEventValidationAndViewState($r);

    // Extract expiryDates for that symbol

    $r['response'] = string_get_after($r['response'], '<select name="mDdlExpDate" id="mDdlExpDate" class="dd" style="text-transform: uppercase">');
    return getSelectOptionValuesAsArray(string_get_before($r['response'], "rnrn"));
    }

// these are used whenever you need to make a request

$prevRequest['eventValidation'] = '';
$prevRequest['viewState'] = '';
$prevRequest['cookie'] = '';
$prevRequest['firstExpiryDate'] = ''; //

// Loads the page, in order to get the symbols

$headers = array();
array_push($headers, 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
array_push($headers, 'Accept-Encoding: gzip, deflate');
array_push($headers, 'Accept-Language: en-US,en;q=0.5');
array_push($headers, 'Cache-Control: no-cache');
array_push($headers, 'Connection: keep-alive');
array_push($headers, 'DNT: 1');
array_push($headers, 'Host: www.mcxindia.com');
array_push($headers, 'Pragma: no-cache');
array_push($headers, 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:21.0) Gecko/20100101 Firefox/21.0');
$r = getPage($headers);
$r['response'] = gzdecode($r['response']);

// print_r($r);die();
// Save the eventValidation and viewState

$prevRequest['eventValidation'] = rawurlencode(valueExtractor($r['response'], '__EVENTVALIDATION'));
$prevRequest['viewState'] = rawurlencode(valueExtractor($r['response'], '__VIEWSTATE'));
$prevRequest['firstExpiryDate'] = getSelectOptionValuesAsArray(string_get_before(string_get_after($r['response'], '<select name="mDdlExpDate" id="mDdlExpDate" class="dd" style="text-transform: uppercase">') , "rnrn"));
$prevRequest['firstExpiryDate'] = rawurlencode($prevRequest['firstExpiryDate'][0]);

// Extract symbols

$d = $r['response'];
$d = string_get_after($d, '<select name="mDdlSymbol" onchange="javascript:setTimeout('__doPostBack('mDdlSymbol', '') ', 0)" id="mDdlSymbol" class="dd">');
$symbols = getSelectOptionValuesAsArray(string_get_before($d, "rnrn"));

// for($i=0; $i<=136; $i++) if($symbols[$i] != 'TURDESI') unset($symbols[$i]);// RUN ONLY FOR ONE SYMBOL
// for($i=0; $i<=136-3; $i++) unset($symbols[$i]);// RUN ONLY FOR LAST X SYMBOLS
// print_r($symbols);die();// View symbols
// Get all CSV files for all symbols*expiryDates

foreach($symbols as $symbol)
    {
    if (SPEAK) echo 'Getting expiryDates for symbol:' . $symbol . " ...";
    $expiryDates = getExpiryDatesForSymbol($symbol);
    if (SPEAK) echo ' DONE' . "n";
    foreach($expiryDates as $expiryDate) getCSVForSymbolAndDate($symbol, $expiryDate);
    }

/*
A .CSV file will look like:

Date,Commodity Symbol,Contract/Expiry Month,Open(Rs),High(Rs),Low(Rs),Close(Rs),PCP(Rs),Volume(In Lots),Volume(In 000's),Value(In Lakhs),OI(In Lots)
06 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,475.25,490.00,0,0.000 KGS,0.00,0
07 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,461.00,475.25,0,0.000 KGS,0.00,0
08 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,461.00,0,0.000 KGS,0.00,0
09 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
10 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
12 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
13 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
14 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
15 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
16 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
17 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
19 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
20 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
21 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
22 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,447.25,447.25,0,0.000 KGS,0.00,0
23 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,447.25,0,0.000 KGS,0.00,0
24 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
26 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
27 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
28 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
29 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
30 Nov 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
01 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
03 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
04 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
05 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
06 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
07 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
08 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
10 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
11 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
12 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
13 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
14 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
15 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
17 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
18 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
19 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
20 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
21 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
22 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
24 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
26 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
27 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,460.75,460.75,0,0.000 KGS,0.00,0
28 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,474.50,460.75,0,0.000 KGS,0.00,0
29 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,474.50,474.50,0,0.000 KGS,0.00,0
31 Dec 2012,ALMOND,28 Feb 2013,0.00,0.00,0.00,474.50,474.50,0,0.000 KGS,0.00,0

*/