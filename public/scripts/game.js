function update(){
  if ($('#state').text() != "wait") return false;
  
  var playerid = $('#playerid').text();
  var gameid = $("#gameid").text();
  $.get('/update',{playerid: playerid, gameid: gameid}, function(data) {
    if (data == "true"){location.reload();}
  });
    
}
$(document).ready(function(){
  setInterval("update()", 4000);
});
