package FlashCards::Plack;
use Plack::Builder;
use Plack::Response;
use FlashCards;
use Sys::Hostname;
use Log::Dispatch;
use Log::Dispatch::File;

sub psgi_app {
    # initial prefix
    my $logger = Log::Dispatch->new(
        outputs => [[
            'File', 
            min_level => 'debug', 
            filename  => 'access', 
            mode      => 'append'
    ]]);

    builder {
        enable "AccessLog::Timed", format => "%h %t %>s %r %b %D", logger => sub {$logger->debug(@_)};

        enable "Deflater",
            vary_user_agent => 1,
            content_type    => ['text/css','text/javascript','application/javascript'];

#        enable "Assets", # 0 - /calculator/fi
#            expires => 60 * 60 * 24 * 365, # 1 year
#            minify  => 1,
#            files   => [
#                "root/js/flot/jquery.flot.js",
#                "root/js/flot/jquery.flot.navigate.js",
#                "root/js/flot/jquery.flot.resize.js",
#                "root/js/networthify.js",
#                "root/js/fi.start.js",
#                "root/js/fi.math.js",
#                "root/js/fi.table.js",
#                "root/js/fi.plot.js",
#                "root/js/fi.end.js",
#            ],
#        ;
#        enable "Assets", # 1
#            expires => 60 * 60 * 24 * 365, # 1 year
#            minify  => 1,
#            files   => [
#                "root/js/flot/jquery.flot.js",
#                "root/js/flot/jquery.flot.selection.js",
#                "root/js/flot/jquery.flot.navigate.js",
#                "root/js/flot/jquery.flot.resize.js",
#                "root/js/networth.js",
#            ],
#        ;
#        enable "Assets", # 2
#            expires => 60 * 60 * 24 * 365, # 1 year
#            minify  => 1,
#            files   => [
#                "root/css/minireset.css",
#                "root/css/networth.css",
#            ],
#        ;
#        enable "Assets", # 3
#            expires => 60 * 60 * 24 * 365, # 1 year
#            minify  => 1,
#            files   => [
#                "root/css/minireset.css",
#                "root/css/networthify.css",
#            ],
#        ;
#        enable "Assets", # 4
#            expires => 60 * 60 * 24 * 365, # 1 year
#            minify  => 1,
#            files   => [
#                "root/upload/js/vendor/jquery.ui.widget.js",
#                "root/upload/js/jquery.iframe-transport.js",
#                "root/upload/js/jquery.fileupload.js",
#                "root/upload/js/jquery.fileupload-ui.js",
#                "root/upload/js/locale.js",
#            ],
#        ;
#        enable "Assets", # 5
#            expires => 60 * 60 * 24 * 365, # 1 year
#            minify  => 1,
#            files   => [
#                "root/upload/css/jquery.fileupload-ui.css",
#                "root//css/jquery-ui-1.8.23.smoothness.css",
#                "root/css/import.css",
#            ],
#        ;
#        enable "Assets", # 6 - /calculator/real-cost
#            expires => 60 * 60 * 24 * 365, # 1 year
#            minify  => 1,
#            files   => [
#                "root/js/networthify.js",
#            ],
#        ;
#
#        enable "Static", root => 'root/', path => 'css/style.less',                     ;
#        enable "Static", root => 'root/', path => 'font/icons.eot',                     ;
#        enable "Static", root => 'root/', path => 'font/icons.svg',                     ;
#        enable "Static", root => 'root/', path => 'font/icons.ttf',                     ;
#        enable "Static", root => 'root/', path => 'font/icons.woff',                    ;
#        enable "Static", root => 'root/', path => 'googlebd4e59492976fb15.html',        ;
#        enable "Static", root => 'root/', path => 'img/calendar.png',                   ;
#        enable "Static", root => 'root/', path => 'img/loading.gif',                    ;
#        enable "Static", root => 'root/', path => 'img/logout.png',                     ;
#        enable "Static", root => 'root/', path => 'img/money.png',                      ;
#        enable "Static", root => 'root/', path => 'img/moneybag.png',                   ;
#        enable "Static", root => 'root/', path => 'img/navy_blue.png',                  ;
#        enable "Static", root => 'root/', path => 'img/noisy_grid.png',                 ;
#        enable "Static", root => 'root/', path => 'img/progressbar.gif',                ;
#        enable "Static", root => 'root/', path => 'img/settings.png',                   ;
#        enable "Static", root => 'root/', path => 'img/wood_pattern.png',               ;
#        enable "Static", root => 'root/', path => 'js/account.js',                      ;
#        enable "Static", root => 'root/', path => 'js/fi.math.js',                      ;
#        enable "Static", root => 'root/', path => 'js/fi.start.js',                     ;
#        enable "Static", root => 'root/', path => 'js/flot/excanvas.min.js',            ;
#        enable "Static", root => 'root/', path => 'js/jquery-1.7.2.min.js',             ;
#        enable "Static", root => 'root/', path => 'js/jquery-1.8.23.datepicker.min.js', ;
#        enable "Static", root => 'root/', path => 'js/jquery.mailcheck.min.js',         ;
#        enable "Static", root => 'root/', path => 'js/less-1.2.1.min.js',               ;
#        enable "Static", root => 'root/', path => 'js/jquery.cookie.js',                ;
#        enable "Static", root => 'root/', path => 'js/networthify.js',                  ;
#        enable "Static", root => 'root/', path => 'upload/img/loading.gif',             ;
#        enable "Static", root => 'root/', path => 'upload/img/progressbar.gif',         ;

        FlashCards->psgi_app;
    }
}

1;
