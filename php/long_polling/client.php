<!DOCTYPE html>
<html>
<head>
<script type="text/javascript" src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
<script type="text/javascript">

function say(data){
	$("#logArea").append(data+"<br/>");
}

$(function(){

	// Create the reader and make it listen
	var xhrReader;
	
	if(window.XMLHttpRequest){// code for IE7+, Firefox, Chrome, Opera, Safari
		xhrReader = new XMLHttpRequest();
	}else{// code for IE6, IE5
		xhrReader = new ActiveXObject("Microsoft.XMLHTTP");
	}
	
	var responseSeek = 0;
	xhrReader.onprogress = function(){
		var update = xhrReader.response.substring(responseSeek, xhrReader.response.length);
		responseSeek = xhrReader.response.length;
		say("update="+update);
	};
	xhrReader.onreadystatechange = function(){
//		say("RSC readyState="+xhrReader.readyState+", status="+xhrReader.status);
//		if(xhrReader.readyState==4 && xhrReader.status==200){
//			alert(xhrReader.responseText);
//		}
	};
		
	xhrReader.open("POST","http://paul.grozav.info/work/php/longPolling/dataInterface.php",true);
	xhrReader.send();
});
</script>
</head>
<body>
<div id="logArea"></div>
 
</body>
</html>


