package FlashCards::Schema::ResultSet::Definition;
use v5.19.6;
use Moo;
extends 'FlashCards::Schema::ResultSet';

sub withPinyin  { shift->search({ pinyin  => shift }) }
sub withEnglish { shift->search({ english => shift }) }


1;
