use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'FlashCards' }
BEGIN { use_ok 'FlashCards::Controller::definition' }

ok( request('/definition')->is_success, 'Request should succeed' );


