// // clock関数 start
// function clock(){
//   var now = new Date();
   
//   var canvas = document.getElementById("clock");
//   var ctx = canvas.getContext('2d');
//   ctx.save();
   
//   canvas.width = 200;
//   canvas.height = 200;
//   var w = canvas.width;
//   var h = canvas.height;
//   var center = {x : w / 2, y : h / 2};
//   var rads = w * 0.375; 
//   ctx.clearRect(0, 0, w, h);
   
//   // 時計の外側の丸
//   ctx.save();
//   ctx.strokeStyle = '#FFF';
//   ctx.shadowBlur = 10;
//   ctx.shadowColor = '#6c757d';
//   ctx.translate(center.x,center.y);
//   ctx.beginPath();
//   ctx.arc(0, 0, w * 0.45, 0, Math.PI * 2, false);
//   ctx.fillStyle = '#6c757d';
//   ctx.fill();
//   ctx.stroke();
//   /* circle white */
//   ctx.beginPath();
//   ctx.arc(0, 0, w * 0.3, 0, Math.PI * 2, false);
//   ctx.fillStyle ="#FFF";
//   ctx.fill();
//   ctx.restore();
   
//   // 文字盤
//   ctx.save();
//   ctx.font = "15px 'sans-serif'";
//   ctx.textAlign = "center";
//   ctx.textBaseline = "middle";
//   ctx.fillStyle = "#FFF";
//   ctx.shadowBlur = 4;
//   ctx.shadowColor = "#FFF";
//   for (var i = 0; i < 12; i++) {
//     var radian = i * Math.PI / 6;
//     var x = center.x + rads * Math.sin(radian);
//     var y = center.y - rads * Math.cos(radian);
//     var text = "" + (i == 0 ? "12" : i);
//     ctx.fillText(text, x, y);
//   }
//   ctx.restore();
   
//   //  中心を移動
//   ctx.translate(center.x,center.y);
   
//   // 分
//   ctx.save();
//   ctx.strokeStyle = '#6c757d';
//   ctx.lineWidth = 1;
//   ctx.beginPath();
//   for (var i=0;i<60;i++){
//     if (i%5!=0) {
//       ctx.moveTo(w * 0.275, 0);
//       ctx.lineTo(w * 0.3, 0);
//     }
//     ctx.rotate(Math.PI/30);
//   }
//   ctx.stroke();
   
//   // 時間
//   ctx.strokeStyle = '#6c757d';
//   ctx.lineWidth = 2;
//   ctx.beginPath();
//   for (var i=0;i<60;i++){
//     ctx.moveTo(w * 0.25, 0);
//     ctx.lineTo(w * 0.3, 0);
//     ctx.rotate(Math.PI/6);
//   }
//   ctx.stroke();
//   ctx.restore();
   
//   // 針の設定
//   var sec = now.getSeconds();
//   var min = now.getMinutes();
//   var hr= now.getHours();
//   hr = hr>=12 ? hr-12 : hr;
//   ctx.fillStyle = "#999";
   
//   // 短針
//   ctx.save();
//   ctx.rotate( hr*(Math.PI/6) + (Math.PI/360)*min + (Math.PI/21600)*sec )
//   ctx.lineWidth = 7;
//   ctx.strokeStyle = '#6c757d';
//   // ctx.shadowBlur = 5;
//   // ctx.shadowColor = "#666";
//   ctx.beginPath();
//   ctx.moveTo(w * -0.01, w * 0.075);
//   ctx.lineTo(0, w * -0.2);
//   // ctx.lineTo(w * 0.01, w * 0.075);
//   ctx.stroke();
//   ctx.restore();
   
//   // 長針
//   ctx.save();
//   ctx.rotate( (Math.PI/30)*min + (Math.PI/1800)*sec )
//   ctx.lineWidth = 3;
//   ctx.strokeStyle = '#6c757d';
//   // ctx.shadowBlur = 10;
//   // ctx.shadowColor = "#999";
//   ctx.beginPath();
//   ctx.moveTo(w * -0.005, w * 0.075);
//   ctx.lineTo(0, w * -0.25);
//   // ctx.lineTo(w * 0.005, w * 0.075);
//   ctx.stroke();
//   ctx.restore();
   
//   // 秒針
//   ctx.save();
//   ctx.rotate(sec * Math.PI/30);
//   ctx.strokeStyle = '#6c757d';
//   ctx.lineWidth = 1;
//   ctx.beginPath();
//   ctx.moveTo(0,w * 0.01);
//   ctx.lineTo(0,w * -0.3);
//   ctx.stroke();
//   ctx.restore();
   
//   // 時計の中心の丸
//   ctx.save();
//   ctx.beginPath();
//   ctx.lineWidth = 2;
//   ctx.strokeStyle = "#FFF";
//   ctx.fillStyle   = "#FFF";
//   ctx.arc(w * 0.007, 0, w * 0.0075, 0, Math.PI*2, true);
//   // ctx.arc(w * 0.007, w * -0.01,w * 0.0075,0,Math.PI*2,true);
//   ctx.stroke();
//   ctx.fill();
//   ctx.restore();
   
//   ctx.restore();
   
// }

window.addEventListener("load", function(){
  // setInterval(clock, 1000);
  setInterval(now_line, 500);
}, false);

var data = function(){
  const navbar = $(".navbar").innerHeight();
  const elem = $("[class^='hm_']")
  const elemheight = elem.innerHeight();
  const sheight = elemheight / 60;
  return [navbar, sheight, elemheight]
}

var date = function(){
  const now = new Date();
  const hour = now.getHours().toString().padStart(2, '0');
  const minute = now.getMinutes().toString().padStart(2, '0');
  const second = now.getSeconds();
  return [hour, minute, second]
}

var margin = function(hour, minute, second, navbar, sheight){
  const elem = $(".hm_" + hour + minute);
  const elemtop = Math.floor(elem.offset().top);
  const px = elemtop - navbar + sheight * second;
  // const px = elemtop - navbar + elemheight / 2 + sheight * second;
  return px
}

function now_line(){
  const dataset = data();
  // const dateset = date();
  $(".now-line").css("marginTop", margin(date()[0], date()[1], date()[2], dataset[0], dataset[1]));
  // $(".now-line").text(dateset[0] + ":" + dateset[1]);
  $(".now-line").text(date()[0] + ":" + date()[1] + ":" + date()[2].toString().padStart(2, "0"));
}

$(function(){
  const dataset = data();
  const dateset = date();
  $(window).scrollTop(margin(dateset[0], dateset[1], dateset[2], dataset[0], dataset[1]) - 200);
  draw(); 
})

function draw() {
  var canvas = document.getElementById('plus');
  if (canvas.getContext) {
    var ctx = canvas.getContext('2d');

    var x = canvas.height;
    var y = canvas.width;

    ctx.beginPath();
    ctx.arc(x*0.5, y*0.5, x*0.45, 0, Math.PI * 2, true); // 外の円
    ctx.fillStyle = "#6c757d"
    ctx.closePath();
    ctx.fill();
    ctx.beginPath();
    ctx.fillStyle = "white"
    ctx.arc(x/2, y*5/20, x*1/20, 0, Math.PI, true);
    ctx.arc(x/2, y*15/20, x*1/20, Math.PI, Math.PI*2, true);
    ctx.fill();
    ctx.beginPath();
    ctx.arc(x*5/20, y/2, y*1/20, Math.PI/2, Math.PI*3/2, false);
    ctx.arc(x*15/20, y/2, y*1/20, Math.PI*3/2, Math.PI/2, false);
    ctx.fill();
  }
}
