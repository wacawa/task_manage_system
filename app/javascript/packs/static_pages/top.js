$(function(){
  var canvas = document.getElementById("24clock");
  var ctx = canvas.getContext('2d');
  ctx.save();
  canvas.width = 400;
  canvas.height = 400;
  var w = canvas.width;
  var h = canvas.height;
  var center = {x : w / 2, y : h / 2};
  var rads = w * 0.45; 
  ctx.clearRect(0, 0, w, h);

  ctx.save();
  ctx.translate(center.x, center.y);
  
  ctx.beginPath();
  ctx.strokeStyle = '#6c757d';
  ctx.arc(0, 0, w * 0.4, 0, Math.PI * 2, false);
  ctx.fillStyle = "#FFF";
  ctx.fill();
  ctx.stroke();

  ctx.beginPath();
  ctx.arc(0, 0, w * 0.1, 0, Math.PI * 2, false);
  ctx.fillStyle = "#6c757d";
  ctx.fill();
  ctx.restore();
   
  ctx.save();
  ctx.font = "15px 'sans-serif'";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  ctx.fillStyle = '#6c757d';
  for (var i = 0; i < 24; i++) {
    var radian = i * Math.PI / 12;
    var x = center.x + rads * Math.sin(radian);
    var y = center.y - rads * Math.cos(radian);
    var text = i;
    ctx.fillText(text, x, y);
  }
  ctx.restore();
   
  ctx.translate(center.x,center.y);
  ctx.font = "14px 'Sacramento', cursive";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  ctx.fillStyle = '#FFF';
  ctx.fillText("TimeBoxing", 0, 0);
   
  ctx.strokeStyle = '#6c757d';
  ctx.lineWidth = 1;
  ctx.beginPath();
  for (var i = 0; i < 24; i++){
    ctx.moveTo(w * 0.1, 0);
    ctx.lineTo(w * 0.4, 0);
    ctx.rotate(Math.PI/12);
  }
  ctx.stroke();
  ctx.restore();
   
  });