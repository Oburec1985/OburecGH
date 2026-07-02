var timeout = 500;
var closetimer = 0;
var ddmenuitem = 0;

function mainmenu_open()
{
  mainmenu_canceltimer();
  mainmenu_close();
  ddmenuitem = $(this).find('ul').eq(0).show();
}

function mainmenu_close()
{
  if(ddmenuitem) ddmenuitem.hide();
}

function mainmenu_timer()
{
  closetimer = window.setTimeout(mainmenu_close, timeout);
}

function mainmenu_canceltimer()
{
  if(closetimer)
  {
    window.clearTimeout(closetimer);
    closetimer = null;
  }
}

function sitecontrol_panel_update(new_state)
{
  var old_state = (new_state == 'on') ? 'off':'on';
  $('#sitecontrol').removeClass('switch_'+old_state).addClass('switch_'+new_state);
  $.cookie('sitecontrol_switcher',new_state,{ path: '/'});
}


function sitecontrol_init()
{
  if (!$('#sitecontrol')) return;
/*
  $('input.theme_select').click(function() {
    $('#sitecontrol .color_select').hide();
    $('#sitecontrol .color_selector').attr('disable',true);

    var id = $(this).attr('id');
    $('#'+id+'_select').show();
    $('#'+id+'_selector').attr('disabled', false);
  });
  */

  var start_state = $.cookie('sitecontrol_switcher');
  if (start_state!='off') start_state="on";
  sitecontrol_panel_update(start_state);

  $('#sitecontrol_switcher_on').click(function() {
    sitecontrol_panel_update('on');
    return false;
  });
  $('#sitecontrol_switcher_off').click(function() {
    sitecontrol_panel_update('off');
    return false;
  });

}





$(document).ready(function()
{
   $('#mainmenu > li').bind('mouseover', mainmenu_open);
   $('#mainmenu > li').bind('mouseout',  mainmenu_timer);

   $(".styled tr").mouseover(function() {$(this).addClass("over");});
   $(".styled tr").mouseout(function() {$(this).removeClass("over");});

   if ($.isFunction($.fn.colorbox) )
   {
     $("a[rel='gallery']").colorbox({width:"75%", height:"75%"});
   }

   if ($.isFunction($.fn.pngFix) )
   {
     $(document).pngFix();
   }

   $(".noautocomplete").attr('autocomplete','off');

   sitecontrol_init();

});

document.onclick = mainmenu_close;
