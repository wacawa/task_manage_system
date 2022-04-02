$(".back-btn").click(function(){
  $(".modal").hide();
})

$(document).on('click', function(e) {
  // if($(".now-line").length){
    var close = $(e.target).attr("class").match(/back-btn/);
    var visible = $(".modal").is(":visible");
    var out = !$(e.target).closest(".modal-dialog").length;
    if(visible && out || close){
      $(".modal").hide();
    }
  // }
})
