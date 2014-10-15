use Test::Most;

use Authen::Passphrase::BlowfishCrypt;
use FlashCards::Schema;
use FlashCards::Test;

my $user;
subtest 'setup' => sub {
    $user = FlashCards::Test->createUser0;
    pass 'created user0 test data';
};

subtest 'change password' => sub {
    my $blowfish = Authen::Passphrase::BlowfishCrypt->new(
       passphrase  => 'pie',
       salt_random => 1,
       cost        => 4,
    );
    $user->update( { password => $blowfish });
    $user = FlashCards::Schema->rs('User')
        ->withUserId($user->userId)
        ->first;

    ok $user->password->match('pie'), 'password()';
};

subtest 'clean username' => sub {
    $user->update( { username => '<div>pie</div>' });
    $user = FlashCards::Schema->rs('User')
        ->withUserId($user->userId)
        ->first;

    is $user->username, 'pie', 'username()';
};

done_testing;
