package FlashCards::Model::Card;

use Fey::ORM::Table;
use Fey::Object::Iterator::FromSelect;
#use FlashCards::Model::Schema;
use FlashCards::Model::UserSet;
use MooseX::Params::Validate;
with 'FlashCards::Model';

my $schema = FlashCards::Model::Schema->Schema;
my $d      = $schema->table('Definition');
my $sd     = $schema->table('SetDefinition');
my $c      = $schema->table('Card');
my $s      = $schema->table('SetOfCards');
my $us     = $schema->table('UserSet');
my $u      = $schema->table('User');

has_table $schema->table('Card');
has_one 'user'       => (table => $schema->table('User'));
has_one 'definition' => (table => $schema->table('Definition'));

# selects 15 of the hardest cards for this user. 
sub difficultCards {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      userId       => {isa => 'Int', optional => 0},
      setId        => {isa => 'Int', optional => 0},
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
         ->from($sd)
         ->from($us)
        ->where($c->column('definitionId'),  '=', $sd->column('definitionId'))
        ->where($sd->column('setId'),        '=', $us->column('setId'))
        ->where($c->column('userId'),        '=', $us->column('userId'))
        ->where($c->column('userId'),        '=', Fey::Placeholder->new())
        ->where($sd->column('setId'),        '=', Fey::Placeholder->new())
        ->where($c->column('definitionId'), '!=', Fey::Placeholder->new())
        ->where($c->column('nextDate'),     '<=', $now)
     ->order_by($orderBy)
        ->limit(FlashCards->config->{difficultCardsLimit});

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $class->meta()->ClassForTable($c) ],
      dbh         => $class->dbh,
      select      => $select,
      bind_params => [ $params{userId}, $params{setId}, $params{definitionId} ],
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

sub initialize {
   my $self = shift or die;
   my %params = validated_hash(\@_,
      userSet      => {isa => 'FlashCards::Model::UserSet', optional => 0},
   );

   my $dbh     = FlashCards::Model::Schema->DBIManager->default_source->dbh;
   my $userSet = $params{userSet};
   my $userId  = $params{userSet}->userId;

   foreach my $question  (qw(english pinyin simplified))  {
      my $sql = "
         insert into Card
                (userId,    definitionId,    question,       startDate,        nextDate)
         select $userId, sd.definitionId, '$question', datetime('now'), datetime('now')
           from SetDefinition sd
          where sd.setId        = ?
         except
         select $userId, sd.definitionId, '$question', datetime('now'), datetime('now')
           from SetDefinition sd,
                Card c
          where sd.definitionId = c.definitionId
            and sd.setId        = ?
            and c.question      = ?
            and c.userId        = ?
      ";
      my $sth = $dbh->prepare($sql);
      $sth->execute($userSet->setId, $userSet->setId, $question, $userSet->userId);
   }

   return undef;
}

# always add card to every user who uses a set
sub add {
   my $self = shift or die;
   my %params = validated_hash(\@_,
      userSet      => {isa => 'FlashCards::Model::UserSet', optional => 0},
      definitionId => {isa => 'Int',                        optional => 0},
   );

   my $dbh          = FlashCards::Model::Schema->DBIManager->default_source->dbh;
   my $userId       = $params{userSet}->userId;
   my $authorId     = $params{userSet}->set->authorId;
   my $definitionId = $params{definitionId};

   foreach my $question (qw(english simplified pinyin)) {
      my $sql = "
         insert into Card
               (userId,  definitionId,    question,       startDate,        nextDate)
         select userId, $definitionId, '$question', datetime('now'), datetime('now')
           from UserSet
          where setId  = ?
         except
         select userId, definitionId, question, datetime('now'), datetime('now')
           from Card
          where definitionId = ?
            and question     = ?
      ";
      my $sth = $dbh->prepare($sql);
      $sth->execute($params{userSet}->setId, $definitionId, $question);
   }

   return undef;
}


1;
