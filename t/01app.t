use Test::Most;
use Catalyst::Test 'FlashCards';

ok( request('/')->is_success, 'Request should succeed' );

done_testing();
