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
#
#        enable "Static", root => 'root/static/', path => 'css/style.less',                     ;
         enable "Static", root => 'root/static/', path => 'js/jquery-1.7.2.min.js',             ;
         enable "Static", root => 'root/static/', path => 'images/icojoy4/001_22.png',          ;

        FlashCards->psgi_app;
    }
}

1;
