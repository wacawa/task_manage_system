window.addEventListener("load", function(){
  setInterval(clock, 1000);
}, false);
   
// clock関数 start
function clock(){
  var now = new Date();
   
  var canvas = document.getElementById("clock");
  var ctx = canvas.getContext('2d');
  ctx.save();
   
  canvas.width = 200;
  canvas.height = 200;
  var w = canvas.width;
  var h = canvas.height;
  var center = {x : w / 2, y : h / 2};
  var rads = w * 0.375; 
  ctx.clearRect(0, 0, w, h);
   
  // 時計の外側の丸
  ctx.save();
  ctx.strokeStyle = '#FFF';
  ctx.shadowBlur = 10;
  ctx.shadowColor = '#6c757d';
  ctx.translate(center.x,center.y);
  ctx.beginPath();
  ctx.arc(0, 0, w * 0.45, 0, Math.PI * 2, false);
  ctx.fillStyle = '#6c757d';
  ctx.fill();
  ctx.stroke();
  /* circle white */
  ctx.beginPath();
  ctx.arc(0, 0, w * 0.3, 0, Math.PI * 2, false);
  ctx.fillStyle ="#FFF";
  ctx.fill();
  ctx.restore();
   
  // 文字盤
  ctx.save();
  ctx.font = "15px 'sans-serif'";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  ctx.fillStyle = "#FFF";
  ctx.shadowBlur = 4;
  ctx.shadowColor = "#FFF";
  for (var i = 0; i < 12; i++) {
    var radian = i * Math.PI / 6;
    var x = center.x + rads * Math.sin(radian);
    var y = center.y - rads * Math.cos(radian);
    var text = "" + (i == 0 ? "12" : i);
    ctx.fillText(text, x, y);
  }
  ctx.restore();
   
  //  中心を移動
  ctx.translate(center.x,center.y);
   
  // 分
  ctx.save();
  ctx.strokeStyle = '#6c757d';
  ctx.lineWidth = 1;
  ctx.beginPath();
  for (var i=0;i<60;i++){
    if (i%5!=0) {
      ctx.moveTo(w * 0.275, 0);
      ctx.lineTo(w * 0.3, 0);
    }
    ctx.rotate(Math.PI/30);
  }
  ctx.stroke();
   
  // 時間
  ctx.strokeStyle = '#6c757d';
  ctx.lineWidth = 2;
  ctx.beginPath();
  for (var i=0;i<60;i++){
    ctx.moveTo(w * 0.25, 0);
    ctx.lineTo(w * 0.3, 0);
    ctx.rotate(Math.PI/6);
  }
  ctx.stroke();
  ctx.restore();
   
  // 針の設定
  var sec = now.getSeconds();
  var min = now.getMinutes();
  var hr= now.getHours();
  hr = hr>=12 ? hr-12 : hr;
  ctx.fillStyle = "#999";
   
  // 短針
  ctx.save();
  ctx.rotate( hr*(Math.PI/6) + (Math.PI/360)*min + (Math.PI/21600)*sec )
  ctx.lineWidth = 7;
  ctx.strokeStyle = '#6c757d';
  // ctx.shadowBlur = 5;
  // ctx.shadowColor = "#666";
  ctx.beginPath();
  ctx.moveTo(w * -0.01, w * 0.075);
  ctx.lineTo(0, w * -0.2);
  // ctx.lineTo(w * 0.01, w * 0.075);
  ctx.stroke();
  ctx.restore();
   
  // 長針
  ctx.save();
  ctx.rotate( (Math.PI/30)*min + (Math.PI/1800)*sec )
  ctx.lineWidth = 3;
  ctx.strokeStyle = '#6c757d';
  // ctx.shadowBlur = 10;
  // ctx.shadowColor = "#999";
  ctx.beginPath();
  ctx.moveTo(w * -0.005, w * 0.075);
  ctx.lineTo(0, w * -0.25);
  // ctx.lineTo(w * 0.005, w * 0.075);
  ctx.stroke();
  ctx.restore();
   
  // 秒針
  ctx.save();
  ctx.rotate(sec * Math.PI/30);
  ctx.strokeStyle = '#6c757d';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(0,w * 0.01);
  ctx.lineTo(0,w * -0.35);
  ctx.stroke();
  ctx.restore();
   
  // 時計の中心の丸
  ctx.save();
  ctx.beginPath();
  ctx.lineWidth = 3;
  ctx.strokeStyle = "#FFF";
  ctx.fillStyle   = "#FFF";
  ctx.arc(w * 0.007, w * -0.01,w * 0.0075,0,Math.PI*2,true);
  ctx.stroke();
  ctx.fill();
  ctx.restore();
   
  ctx.restore();
   
}

$(function(){
  var hour = new Date().getHours();
  if(1 < hour < 21){
    var one_hour_ago = hour - 2;
    var now_hour = ".hour_" + one_hour_ago;
    var hour = $(now_hour);
    $(window).scrollTop(hour.offset().top);
  }
});