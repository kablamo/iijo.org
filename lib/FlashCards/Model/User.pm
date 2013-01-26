package FlashCards::Model::User;

use Authen::Passphrase;
use Fey::ORM::Table;
use FlashCards::Model::Schema;
use HTML::Scrubber;
use MooseX::Params::Validate;
with 'FlashCards::Model';


my $schema = FlashCards::Model::Schema->Schema;
my $d      = $schema->table('Definition');
my $sd     = $schema->table('SetDefinition');
my $ld     = $schema->table('SelectedDefinition');
my $c      = $schema->table('Card');
my $s      = $schema->table('SetOfCards');
my $us     = $schema->table('UserSet');
my $u      = $schema->table('User');

has_table $schema->table('User');
has_many 'userSets'            => (table => $schema->table('UserSet'));
has_many 'selectedDefinitions' => (table => $schema->table('SelectedDefinition'));

transform 'username'
   => inflate { 
         my $u = $_[1];
         $u = HTML::Scrubber->new(allow => [])->scrub($u);
         return 'guest user'
            if (length($u) == 32 && $u !~ /\s/);
         return $u;
         
};

transform 'password' => { 
    inflate => sub { Authen::Passphrase->from_rfc2307($_[1]) },
    deflate => sub { $_[1]->as_rfc2307() },
};



my $totalCount     = Fey::Literal::Function->new('count', '*');
my $totalCardCount = Fey::Literal::Term->new($totalCount, '* 3');
my $totalCards     = FlashCards::Model::Schema->SQLFactoryClass()->new_select()
       ->select($totalCardCount)
         ->from($ld)
         ->from($us)
        ->where($us->column('userId'), '=', $ld->column('userId'))
        ->where($us->column('setId'),  '=', $ld->column('setId'))
        ->where($ld->column('userId'), '=', Fey::Placeholder->new());

has 'totalCards' => (
   metaclass   => 'FromSelect',
   is          => 'ro',
   isa         => 'Int',
   select      => $totalCards,
   bind_params => sub { $_[0]->userId },
);



my $completedCount = Fey::Literal::Function->new('count', '*');
my $completedNow   = Fey::Literal::Function->new('datetime', 'now');
my $completedCards = FlashCards::Model::Schema->SQLFactoryClass()->new_select()
       ->select($completedCount)
         ->from($c)
         ->from($ld)
         ->from($us)
        ->where($c->column('definitionId'), '=', $ld->column('definitionId'))
        ->where($ld->column('userId'),      '=', $us->column('userId'))
        ->where($ld->column('setId'),       '=', $us->column('setId'))
        ->where($c->column('userId'),       '=', $ld->column('userId'))
        ->where($us->column('userId'),       '=', Fey::Placeholder->new()) # have to use us.userId here or else sqlite is really really really slow for some reason
        ->where($c->column('nextDate'),     '>', $completedNow);

has 'completedCards' => (
   metaclass   => 'FromSelect',
   is          => 'ro',
   isa         => 'Int',
   select      => $completedCards,
   bind_params => sub { $_[0]->userId },
);



sub cardsLeft {
   my $self = shift or die;

   return $self->totalCards - $self->completedCards;
}

sub pctComplete {
   my $self = shift or die;

   my $pctComplete;
   if ($self->totalCards == 0) {
      return sprintf("%.1f", 0) . '%';
   }
   else {
      my $x = (($self->totalCards - $self->cardsLeft) / $self->totalCards) * 100;
      return sprintf("%.1f", $x) . '%';
   }
}

# selects 15 of the hardest cards for this user. 
sub difficultCards {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      userId       => {isa => 'Int', optional => 0},
      definitionId => {isa => 'Int', optional => 0, default => 0},
   );

   my $now      = Fey::Literal::Function->new('datetime', 'now');
   my $future   = Fey::Literal::Number->new('2142081107');
   my $strfNow  = Fey::Literal::Function->new('strftime', '%s', $now);
   my $strfNext = Fey::Literal::Function->new('strftime', '%s', $c->column('nextDate'));
   my $coalesce = Fey::Literal::Function->new('coalesce', $strfNext, $future);
   my $orderBy  = Fey::Literal::Term->new($strfNow, '-', $coalesce);
   my $select   = FlashCards::Model::Schema->SQLFactoryClass()->new_select()
       ->select($c)
         ->from($c)
         ->from($ld)
         ->from($us)
        ->where($us->column('setId'),        '=', $ld->column('setId'))
        ->where($us->column('userId'),       '=', $ld->column('userId'))
        ->where($c->column('definitionId'),  '=', $ld->column('definitionId'))
        ->where($c->column('userId'),        '=', $ld->column('userId'))
        ->where($us->column('userId'),       '=', Fey::Placeholder->new())
        ->where($c->column('definitionId'), '!=', Fey::Placeholder->new())
        ->where($c->column('nextDate'),     '<=', $now)
     ->order_by($orderBy)
        ->limit(FlashCards->config->{difficultCardsLimit});

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $class->meta()->ClassForTable($c) ],
      dbh         => $class->dbh,
      select      => $select,
      bind_params => [ $params{userId}, $params{definitionId} ],
   );
}

# randomly choose one of the most difficult 15 cards
sub ask {
   my $class  = shift or die;
   my $limit = FlashCards->config->{difficultCardsLimit};

   my @cards = $class->difficultCards(@_)->all;

   my $size = scalar(@cards);
   return undef if $size == 0;

   $limit = $size if $size < $limit;

   srand;
   my $index = int(rand($limit)); 
   # my $index = one of: 0,1,2,...,($limit - 1)

   return $cards[$index];
}


1;
