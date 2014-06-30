use Test::Most;

use FlashCards::Schema;
use FlashCards::Test;

my $user;
subtest 'setup' => sub {
    $user = FlashCards::Test->createUser0;
    pass 'created user0 test data';
};

subtest 'pinyin inflation' => sub {
    my $definition = FlashCards::Schema->rs('Definition')
        ->limit(1)
        ->next;
   #is ref $definition->pinyin, 'CEDict::Pinyin', 'test object type';
    unlike $definition->pinyin, qr/[1234]/, 'number converted to diacritics';
};

subtest 'english inflation' => sub {
    my $definition = FlashCards::Schema->rs('Definition')
        ->withEnglish({ 'like' => '%/%' })
        ->limit(1)
        ->next;
    like $definition->english, qr/^\<div/, 'wrapped in html';

    $definition = FlashCards::Schema->rs('Definition')
        ->withEnglish({ 'not like' => '%/%' })
        ->limit(1)
        ->next;
    unlike $definition->english, qr/^\<div/, 'not wrapped with html';
};

done_testing;
