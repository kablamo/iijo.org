package FlashCards::Schema::ResultSet::User;
use v5.19.6;
use Moo;
extends 'FlashCards::Schema::ResultSet';

sub withUsername { shift->search({ username => shift}) }
sub withUserId   { shift->search({ userId   => shift}) }

1;
