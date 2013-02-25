package FlashCards::Model::UserSet;

use Fey::ORM::Table;
use FlashCards::Model::Card;
use FlashCards::Model::Schema;
use FlashCards::Model::SetOfCards;
use FlashCards::Model::UserSet;
use Math::Random::MT qw(srand rand);
use MooseX::Params::Validate;
with 'FlashCards::Model';


my $schema = FlashCards::Model::Schema->Schema;
my $d      = $schema->table('Definition');
my $sd     = $schema->table('SetDefinition');
my $c      = $schema->table('Card');
my $s      = $schema->table('SetOfCards');
my $us     = $schema->table('UserSet');
my $u      = $schema->table('User');


has_table $us;
has_one  'user' => (table => $u);
has_one  'set'  => (table => $s);

has 'definitionId' => (
   is  => 'rw',
   isa => 'Int',
);



my $count     = Fey::Literal::Function->new('count', '*');
my $cardCount = Fey::Literal::Term->new($count, '* 3');
my $totalCards     = FlashCards::Model::Schema->SQLFactoryClass()->new_select()
       ->select($cardCount)
         ->from($sd)
         ->from($us)
        ->where($us->column('setId'),  '=', $sd->column('setId'))
        ->where($us->column('setId'),  '=', Fey::Placeholder->new)
        ->where($us->column('userId'), '=', Fey::Placeholder->new);

has 'totalCards' => (
   metaclass   => 'FromSelect',
   is          => 'ro',
   isa         => 'Int',
   select      => $totalCards,
   bind_params => sub { $_[0]->setId, $_[0]->userId },
);



my $completedCount = Fey::Literal::Function->new('count', '*');
my $completedNow   = Fey::Literal::Function->new('datetime', 'now');
my $completedCards = FlashCards::Model::Schema->SQLFactoryClass()->new_select()
       ->select($completedCount)
         ->from($c)
         ->from($sd)
        ->where($c->column('definitionId'), '=', $sd->column('definitionId'))
        ->where($c->column('userId'),       '=', $sd->column('userId'))
        ->where($c->column('userId'),       '=', Fey::Placeholder->new())
        ->where($sd->column('setId'),       '=', Fey::Placeholder->new())
        ->where($c->column('nextDate'),     '>', $completedNow);

has 'completedCards' => (
   metaclass   => 'FromSelect',
   is          => 'ro',
   isa         => 'Int',
   select      => $completedCards,
   bind_params => sub { $_[0]->userId, $_[0]->setId },
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

# should put this in a policy
sub selectMany {
   my $class = shift or die;
   my %paramSpec = ();
   my @columns = $us->columns();
   foreach my $c (@columns) {
      $paramSpec{$c->name} = {optional => 1};
   }
   $paramSpec{page}    = {isa => 'Int', optional => 0, default => 0};
   $paramSpec{orderBy} = {              optional => 0, default => 'name'};
   my %params = validated_hash(\@_, %paramSpec);
   my $pageSize = FlashCards->config->{pageSize};
   my $page     = delete $params{page};
   my $orderBy  = delete $params{orderBy};
   my @values   = values %params;

   my $select = $class->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($us, $s)
            ->from($us, $s) 
        ->order_by($s->column($orderBy));

   foreach my $col (keys %params) {
      $select->where($us->column($col), '=', Fey::Placeholder->new());
   }

   $select->limit($pageSize, $page * $pageSize);

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $class->meta()->ClassForTable($us) ],
      dbh         => $class->dbh,
      select      => $select,
      bind_params => \@values,
   );
}

sub newOrInsert {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      userId => {isa => 'Int', optional => 0},
      setId  => {isa => 'Int', optional => 0},
   );

   my $userSet = FlashCards::Model::UserSet->new(
      userId  => $params{userId},
      setId   => $params{setId},
   );
   return $userSet if defined $userSet;

   # validate setId
   my $set = FlashCards::Model::SetOfCards->new(setId => $params{setId});
   die "unknown setId" unless defined $set;

   $userSet = FlashCards::Model::UserSet->insert(
      userId  => $params{userId},
      setId   => $params{setId},
   );

   FlashCards::Model::Card->initialize(userSet => $userSet);

   return $userSet;
}

1;
