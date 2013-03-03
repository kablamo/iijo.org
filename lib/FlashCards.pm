package FlashCards;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use Sys::Hostname qw/hostname/;
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
/;
#    Unicode::Encoding

extends 'Catalyst';
with 'CatalystX::AuthenCookie';        # cookie authentication
with 'CatalystX::FlashCards::User';    # authenticate users with AuthenCookie
with 'CatalystX::Slug';                # create slugs for urls

our $VERSION = '0.01';

# Settings in flashcards.conf take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.
$ENV{CATALYST_DEBUG} = 1 if hostname eq 'eric';

__PACKAGE__->config(
    name                => 'FlashCards',
    pageSize            => 25,
    difficultCardsLimit => 15,
    root => dir('.', 'root')->absolute,
    home => dir('.', )->absolute,
    default_view        => 'TT',
    ttTimer             => 0,

    'Plugin::ConfigLoader' => { file => 'flashcards.conf' },

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header

    'Log::Dispatch' => [{
        class     => 'File',
        name      => 'file',
        min_level => 'warning',
        filename  => 'errors',
        mode      => 'append',
    }],
    
    authen_cookie       => { mac_secret => '123456789' },

    encoding => 'UTF-8',
);

if (hostname eq 'laptop') {
    __PACKAGE__->config->{'Log::Dispatch'}->[0]->{min_level} = 'debug';
}

# Start the application
__PACKAGE__->setup;

1;
