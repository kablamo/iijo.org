var ratb = {
ShowAnswer : function() {
   window.location.href = $("#show a").attr('href');
},
HotKeyBindings : function() {
   $(document).bind('keydown', 'space', ratb.ShowAnswer);
   $(document).bind('keydown', 's',     ratb.ShowAnswer);
}
}
jQuery(function ($) {
   ratb.HotKeyBindings();
});
