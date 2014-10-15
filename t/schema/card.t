use Test::Most;

use FlashCards::Schema;
use FlashCards::Test;

my $user;
subtest 'setup' => sub {
    $user = FlashCards::Test->createUser0;
    pass 'created user0 test data';
};

subtest 'completed' => sub {
    my $completed = $user->search_related('cards')->completed->count;
    is $completed, 4, 'completed()';
};

subtest 'difficult' => sub {
    my $difficult_cards = $user->search_related('cards')
        ->difficult()
        ->limit(3);

    is $difficult_cards->next->nextDate->ymd, 
       DateTime->today->add(days => -1)->ymd, 
       'difficulty 2';

    is $difficult_cards->next->nextDate->ymd, 
       DateTime->today->add(days => -2)->ymd, 
       'difficulty 1';
};

done_testing;
