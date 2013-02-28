use strict;
use warnings;

use Plack::Builder;
use Plack::App::Directory;
use FlashCards::Plack;

builder {
    mount '/' => FlashCards::Plack->psgi_app;
}

