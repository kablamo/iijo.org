package FlashCards;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;
use Sys::Hostname qw/hostname/;
use Path::Class qw/dir/;

#    Cache::HTTP: etags and last-modified header
#   ConfigLoader: load configuration
# Compress::Gzip: gzip files if browser requests it
# Static::Simple: serve static files from the application's root directory
#     StackTrace: does what?
use Catalyst qw/
    Cache::HTTP
    ConfigLoader
    Compress::Gzip
    Static::Simple
    StackTrace
/;

extends 'Catalyst';

with 'CatalystX::AuthenCookie';        # cookie authentication
with 'CatalystX::FlashCards::User';    # authenticate users with AuthenCookie
with 'CatalystX::Slug';                # create slugs for urls

our $VERSION = '0.01';

# Settings in networth.conf take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.
$ENV{CATALYST_DEBUG} = 1 if hostname eq 'eric';

__PACKAGE__->config(
    name => 'FlashCards',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    'Plugin::ConfigLoader' => { file => 'flashcards.conf' },
    root => dir('.', 'root')->absolute,
    home => dir('.', )->absolute,
    default_view        => 'TT',
    pageSize            => 25,
    difficultCardsLimit => 15,
    ttTimer             => 0,
    authen_cookie       => { mac_secret => '123456789' },
    recaptcha           => {
        publicKey  => '6Le31rwSAAAAAP_YNUSySH8-joJ7D8qfvYhyxvib',
        privateKey => '123',
    },
);

# Start the application
__PACKAGE__->setup;

1;
