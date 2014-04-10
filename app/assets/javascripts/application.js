// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

function newWindow(link,width,height) {
    var atrybuty='menubar=no, toolbar=no, location=no, scrollbars=yes, width=' + width + ', height=' + height;
    window.open(link,'Udostępnij wpis',atrybuty);
}

/* show flash message */
function flash_window(type){
  $("#flash_messages,#flash_confirm,#flash_dialog,#flash_editor").hide()
  if(type=='confirm'){
      $('#flash_confirm').show();
  } else if(type=='dialog'){
      $('#flash_dialog').show();
  } else if(type=='editor'){
      $('#flash_editor').show();
  } else {
      $('#flash_messages').show();
  }
  $('.f_outer').show();
}

function flash_window_close(){
  $('.f_outer').fadeOut('fast');
}

function delay_flash_window_close(message){
  if(message != null){
    flash_window()
    $('#flash_messages .content').html(message)
  }
  $('.f_outer').delay(1500).fadeOut('fast');
}

function block_editor(){
    window.onbeforeunload = function() {
      return "Jestes pewien ze chcesz opuscic ta strone ?";
    }
}

$(document).ready(function() {

      /* AUTOGROW */
      $("#thr_content").autoGrow();
      $("#an_content").autoGrow();

      $("#versions_toggle").on('click', function () {
          $(this).parent().parent().children(".mods").slideToggle('slow');
      });

      $("#select_version").on('change',function() {
          form = $(this).parent().parent();
          recentaction = form.attr('action');
          form.attr('action',recentaction + '/edit');
          form.submit();
      });

      $("#select_acomment").on('change',function(){
         $('textarea#acomment').val($(this).val())
      });


      /*
       *    If you want confirmation on event class ..class="remote-delete"..
       *    use ..class="_confirm-remote-delete".. instead to display confirmation flash message.
       *    Requirments:
       *    so flash message confirmation link must exists and look like
       *    <a href="this-will-be-replace" class="_confirm another_class" >
       *    <a class="_close another_class" >
       *
       *    stosowac:
       *    :class=> '_confirm-remote-delete',"data-confirmation" => 'czy chcesz usunac ta odpowiedz ?'
      */
      $('a[class|="_confirm"]').on('click', function () {
          $("#flash_confirm .content").html($(this).attr('data-confirmation'))
          flash_window('confirm');
          action_class = $(this).attr('class').match(/_confirm-[\S]+/).join().slice(9)
          $("#flash_confirm ._confirm").attr('href',this.href).addClass(action_class)
          return false;
      });

      $('body').on('click','#flash_confirm ._confirm', function () {
          flash_window_close()
          return false;
      });

      $('a[class|="_flash"]').on('click', function() {
          $.getScript($(this).attr("href"),function(){
          });
          return false;
      });

      $('.flash_window').on('click','._close', function () {
          flash_window_close()
          return false;
      });

      // zamykanie komenta, narazie tyle musi wystarczyc
      $('body').on('click','._close_comment', function () {
          $(this).parents('.comments').children('.new_comment_a').show()
          $(this).parents('.new_comment').hide()
          return false;
      })

      /* AJAX LINKS */
      /*
       * #site .pagination a
       */
      $('body').on('click','.favorite a.fav, .sortable a, #add_comment, #edit_comment, .votes a.plus, .votes a.minus', function () {
         $.getScript($(this).attr("href"));
         return false;
      });

      /* AJAX FORM REQUEST */
      /*
       *form#new_an,
       */
      $('body').on("submit",'form.remote-submit',function() {
          $.ajax({
             type: $(this).attr("method"),
             url: $(this).attr("action"),
             data: $(this).serialize(),
             dataType: 'script',
             beforeSend: function(){

             }
          });
          return false;
      });

      $('body').on('click','a.remote-update', function () {
          $.ajax({
             type: 'post',
             url: this.href,
             data: { _method: 'put',
                     authenticity_token: $("meta[name='csrf-token']").attr("content")
                   },
             dataType: 'script'
          });
          return false;
      });

      $('body').on('click','a.remote-delete', function () {
          $.ajax({
             type: 'post',
             url: this.href,
             data: { _method: 'delete',
                     authenticity_token: $("meta[name='csrf-token']").attr("content")
                   },
             dataType: 'script'
          });
          return false;
      });

      function search_thrs(){
          term = $("#thr_title").val()
          if(term.length > 2){
              $.getScript('/search?term='+term);
          }
      }

      var handlerTimeout;

      $("#thr_title").keypress(function(event){
          if (event.keyCode == '13') {
            return false
          }
          if(handlerTimeout) {
            clearTimeout(handlerTimeout);
            handlerTimeout = null;
          }
          handlerTimeout = setTimeout(search_thrs, 500)
      });
//
//
//      if ($(".search_input").val() == ''){
//          $(".search_input").val('szukaj...');
//          $(".search_input").focus(function(){
//            $(this).val('');
//          })
//      }

});