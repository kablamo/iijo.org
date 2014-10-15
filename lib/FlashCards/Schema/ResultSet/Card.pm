package FlashCards::Schema::ResultSet::Card;
use v5.19.6;
use Moo;
extends 'FlashCards::Schema::ResultSet';

sub withNextDate { shift->search({ nextDate => shift }) }

sub completed {
    shift->search({ 'nextDate' => { '>', \"datetime('now')"}});
}

# Returns cards whose nextDate shows they need to be practiced ordered by
# difficulty.
sub difficult {
    shift->withNextDate({ '<=', \"datetime('now')" })
         ->orderByDifficulty;
}

# cards whose nextDate is < now are more difficult
# cards whose nextDate is > now are less difficult
# cards with null nextDate are the least difficult
sub orderByDifficulty {
    shift->orderBy(\q|strftime('%s', datetime('now')) - coalesce(strftime('%s', nextDate), '2142081107')|);
}

1;
