function reset_app() {
  open_box("upload_box");
}

Shiny.addCustomMessageHandler("enable_next", function(x) {
  
  $("#" + x).prop('disabled', false);
  
});

function open_box(box_id, close_others = true) {
  
  $(".box").each(function(index) {
    if($(this).find('.box-body').attr('id') === box_id) {
      if($(this).hasClass("collapsed-box")) {
        $(this).find('[data-widget=collapse]').click();
      }
    } else if(close_others === true) {
      if($(this).hasClass("collapsed-box") === false) {
        $(this).find('[data-widget=collapse]').click();
      }
    }
  });
  
}