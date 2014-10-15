package FlashCards::Test::Data;
use v5.19.6;
use strict;
use warnings;

use DateTime::Format::SQLite;

sub now { FlashCards::Utils->now }

sub sqlite_format { DateTime::Format::SQLite->format_datetime(shift) }

sub createUser0 {
    my $user0 = FlashCards::Schema->rs('User')->create({ 
        username => 'test0',
        email    => 'test0',
        guest    => 'n',
        slug     => 'test0',
    });

    my $plus1day   = sqlite_format( DateTime->now->add(      days => 1 ) );
    my $minus1day  = sqlite_format( DateTime->now->subtract( days => 1 ) );
    my $minus2days = sqlite_format( DateTime->now->subtract( days => 2 ) );
    my $now        = sqlite_format( DateTime->now );
    my @all_questions = qw/english simplified complex pinyin/;

    my $definition0 = FlashCards::Schema->rs('Definition')->create({
        english    => 'apple',
        simplified => '苹果',
        complex    => '苹果',
        pinyin     => 'ping1 guo3',
    });

    FlashCards::Schema->rs('Card')->create({
        userId       => $user0->userId,
        definitionId => $definition0->definitionId,
        question     => $_,
        startDate    => $now,
        nextDate     => $plus1day,
    }) for @all_questions;

    my $definition1 = FlashCards::Schema->rs('Definition')->create({
        english    => 'superman',
        simplified => '超人',
        complex    => '超人',
        pinyin     => 'chao1 ren2',
    });

    FlashCards::Schema->rs('Card')->create({
        userId       => $user0->userId,
        definitionId => $definition1->definitionId,
        question     => 'english',
        startDate    => $now,
        nextDate     => $minus2days,
    });
    FlashCards::Schema->rs('Card')->create({
        userId       => $user0->userId,
        definitionId => $definition1->definitionId,
        question     => 'pinyin',
        startDate    => $now,
        nextDate     => $minus1day,
    });

    my $definition2 = FlashCards::Schema->rs('Definition')->create({
        english    => 'dragon',
        simplified => '龙',
        complex    => '龙',
        pinyin     => 'long2',
    });

    FlashCards::Schema->rs('Card')->create({
        userId       => $user0->userId,
        definitionId => $definition2->definitionId,
        question     => 'pinyin',
        startDate    => $now,
    });

    my $definition3 = FlashCards::Schema->rs('Definition')->create({
        english    => 'good',
        simplified => '好',
        complex    => '好',
        pinyin     => 'hao',
    });
    my $definition4 = FlashCards::Schema->rs('Definition')->create({
        english    => 'bad',
        simplified => '坏',
        complex    => '坏',
        pinyin     => 'hua4',
    });
    my $definition5 = FlashCards::Schema->rs('Definition')->create({
        english    => 'one by one/one after another',
        simplified => '一一',
        complex    => '一一',
        pinyin     => 'yi1 yi1',
    });


#    my $preferences = FlashCards::Schema->rs('Preference')->create({ 
#        userId         => $user0->userId,
#        currencyCode   => 'USD',
#        withdrawalRate => 4.0,
#        roi            => 7.0,
#        hourlyWage     => 20.0,
#        workDay        => 8.0,
#        daysPerYear    => 232.0,
#    });
#
#    my $account0 = FlashCards::Schema->rs('Account')->create({ 
#        userId => $user0->userId,
#        name   => 'Checking',
#    });
#    my $account1 = FlashCards::Schema->rs('Account')->create({ 
#        userId => $user0->userId,
#        name   => 'Savings',
#    });
#
#    my $userId     = $user0->userId;
#    my $accountId0 = $account0->accountId;
#    my $accountId1 = $account1->accountId;
#    FlashCards::Schema->rs('Asset')->populate([
#        [ qw/ userId accountId description value date tag /],
#        [ $userId, $accountId0, 'spiderman underpants', -30.00, now()->clone->subtract(days => 9)->ymd, 'clothes' ],
#        [ $userId, $accountId0,    'batman underpants', -20.00, now()->clone->subtract(days => 8)->ymd, 'clothes' ],
#        [ $userId, $accountId0,              'cabbage',  -3.00, now()->clone->subtract(days => 7)->ymd, 'food'    ],
#        [ $userId, $accountId0,           'miso paste',    -90, now()->clone->subtract(days => 6)->ymd, 'food'    ],
#        [ $userId, $accountId0,      'Big Corporation',    990, now()->clone->subtract(days => 5)->ymd, 'salary'  ],
#        [ $userId, $accountId1, 'spiderman underpants', -20.00,                             now()->ymd, 'clothes' ],
#        [ $userId, $accountId1,    'batman underpants', -20.00,                             now()->ymd, 'clothes' ],
#        [ $userId, $accountId1,              'cabbage',  -3.00,                             now()->ymd, 'food'    ],
#    ]);

    return $user0;
}

sub createUser1 {
    my $user1 = FlashCards::Schema->rs('User')->create({ 
        username => 'test1',
        email    => 'test1',
        guest    => 'n',
        slug     => 'test1',
    });

    my $preferences = FlashCards::Schema->rs('Preference')->create({ 
        userId         => $user1->userId,
        currencyCode   => 'USD',
        withdrawalRate => 4.0,
        roi            => 7.0,
        hourlyWage     => 20.0,
        workDay        => 8.0,
        daysPerYear    => 232.0,
    });

    my $account0 = FlashCards::Schema->rs('Account')->create({ 
        userId => $user1->userId,
        name   => 'Checking',
    });
    my $account1 = FlashCards::Schema->rs('Account')->create({ 
        userId => $user1->userId,
        name   => 'Savings',
    });

    my $userId     = $user1->userId;
    my $accountId0 = $account0->accountId;
    my $accountId1 = $account1->accountId;
    FlashCards::Schema->rs('Asset')->populate([
        [ qw/ userId accountId description value date tag /],
        [ $userId, $accountId0, 'spiderman underpants', -20.00, now()->ymd, 'clothes'],
        [ $userId, $accountId0, 'batman underpants',    -20.00, now()->ymd, 'clothes'],
        [ $userId, $accountId0, 'cabbage',               -3.00, now()->ymd, 'food'   ],
        [ $userId, $accountId1, 'spiderman underpants', -20.00, now()->ymd, 'clothes'],
        [ $userId, $accountId1, 'batman underpants',    -20.00, now()->ymd, 'clothes'],
        [ $userId, $accountId1, 'cabbage',               -3.00, now()->ymd, 'food'   ],
    ]);

    return $user1;
}

1;
