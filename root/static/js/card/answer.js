var ratb = {
WrongAnswer : function() {
   window.location.href = $("#wrong a").attr('href');
},
RightAnswer : function() {
   window.location.href = $("#right a").attr('href');
},
HotKeyBindings : function() {
   $(document).bind('keydown', 'alt+r', ratb.RightAnswer);
   $(document).bind('keydown', 'r',     ratb.RightAnswer);
   $(document).bind('keydown', 'alt+w', ratb.WrongAnswer);
   $(document).bind('keydown', 'w',     ratb.WrongAnswer);
}
}
jQuery(function ($) {
   ratb.HotKeyBindings();
});
