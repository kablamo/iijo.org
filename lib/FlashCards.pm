package FlashCards;
use Moose;

use Catalyst::Runtime 5.80;
use FlashCards::Utils;
use Path::Class qw/dir/;

#         Assets: css and js concat/minification
#    Cache::HTTP: etags and last-modified header
#   ConfigLoader: load configuration
# Compress::Gzip: gzip files if browser requests it
#  Log::Dispatch: more control over logging
# Static::Simple: serve static files from the application's root directory
use Catalyst qw/
    Assets
    Cache::HTTP
    ConfigLoader
    Log::Dispatch
    StackTrace
    Unicode::Encoding
/;

extends 'Catalyst';
with 'CatalystX::AuthenCookie';        # cookie authentication
with 'CatalystX::FlashCards::User';    # authenticate users with AuthenCookie
with 'CatalystX::Slug';                # create slugs for urls

$ENV{CATALYST_DEBUG}      = 1 if FlashCards::Utils->dev_mode;
$ENV{DBIC_RT79576_NOWARN} = 1; # see http://v.gd/DBIC_SQLite_RT79576

__PACKAGE__->config(
    name                                        => 'FlashCards',
    encoding                                    => 'UTF-8',
    enable_catalyst_header                      => 1, # Send X-Catalyst header
    disable_component_resolution_regex_fallback => 1, # Disable deprecated behavior
    pageSize                                    => 25,
    difficultCardsLimit                         => 15,
    root                                        => dir('.', 'root')->absolute,
    home                                        => dir('.', )->absolute,
    default_view                                => 'TT',
    ttTimer                                     => 0,

    'View::JSON'    => { expose_stash => 'json' },
    'Log::Dispatch' => [{
        class     => 'File',
        name      => 'file',
        min_level => 'warning',
        filename  => 'errors',
        mode      => 'append',
    }],
);

__PACKAGE__->config->{'Log::Dispatch'}->[0]->{min_level} = 'debug'
    if FlashCards::Utils->dev_mode;

# Start the application
__PACKAGE__->setup();

1;
