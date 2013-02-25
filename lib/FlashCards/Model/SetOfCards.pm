package FlashCards::Model::SetOfCards;

use MooseX::Params::Validate;
use Fey::ORM::Table;
use FlashCards::Model::Schema;
use HTML::Scrubber;
use Data::Dumper::Concise;
with 'FlashCards::Model';

my $schema = FlashCards::Model::Schema->Schema;
my $d      = $schema->table('Definition');
my $sd     = $schema->table('SetDefinition');
my $s      = $schema->table('SetOfCards');
my $us     = $schema->table('UserSet');
my $u      = $schema->table('User');

has_table $schema->table('SetOfCards');
has_many 'setDefinitions' => (table => $sd);
has_one  'author'         => (table => $u);

transform 'name'
   => inflate { defined $_[1]? HTML::Scrubber->new(allow => [])->scrub($_[1]) : undef; };

transform 'description'
   => inflate { defined $_[1]? HTML::Scrubber->new(allow => [])->scrub($_[1]) : undef; };


my $countUsers = Fey::Literal::Function->new('count', $us->column('userId'));
my $users = FlashCards::Model::Schema->SQLFactoryClass()->new_select()
      ->select($countUsers)
        ->from($us, $u)
       ->where($us->column('setId'), '=', Fey::Placeholder->new())
       ->where($u->column('guest'), '=', Fey::Placeholder->new());
# where user is is not a guest

has 'users' => (
   metaclass   => 'FromSelect',
   is          => 'ro',
   isa         => 'Int',
   select      => $users,
   bind_params => sub { $_[0]->setId, 'n' },
);



my $totalCount     = Fey::Literal::Function->new('count', '*');
my $totalCardCount = Fey::Literal::Term->new($totalCount, '* 3');
my $totalCards     = FlashCards::Model::Schema->SQLFactoryClass()->new_select()
       ->select($totalCardCount)
         ->from($sd)
        ->where($sd->column('setId'),  '=', Fey::Placeholder->new());

has 'totalCards' => (
   metaclass   => 'FromSelect',
   is          => 'ro',
   isa         => 'Int',
   select      => $totalCards,
   bind_params => sub { $_[0]->setId },
);

sub search {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      query  => {isa => 'Str', optional => 0},
      column => {isa => 'Str', optional => 0},
      page   => {isa => 'Int', optional => 1, default => 0},
   );
   my $column   = $params{column};
   my $query    = $params{query};
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};

   my $select = $self->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($d)
            ->from($sd, $d)
           ->where($sd->column('setId'),   '=', Fey::Placeholder->new())
           ->where('(')
           ->where($d->column($column), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($d->column($column), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($d->column($column), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($d->column($column), 'like', Fey::Placeholder->new())
           ->where(')')
           ->limit($pageSize, $page * $pageSize);

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $self->meta()->ClassForTable($d) ],
      dbh         => $self->dbh,
      select      => $select,
      bind_params => [ 
                        $self->setId, 
                        $query, 
                        $query . '/%', 
                        '%/' . $query, 
                        '%/' . $query . '/%' 
                     ],
   );
}

sub definitions {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      page    => {isa => 'Int', optional => 1, default => 0},
   );
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};

   my $sql = $self->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($sd, $d, $u)
            ->from($sd, $d)
            ->from($sd, $u)
           ->where($sd->column('authorId'), '=', $u->column('userId'))
           ->where($sd->column('setId'),    '=', Fey::Placeholder->new())
           ->limit($pageSize, $page * $pageSize)
        ->order_by($d->column('pinyin'));

   return Fey::Object::Iterator::FromSelect->new(
      classes       => [ $self->meta()->ClassForTable($sd), $self->meta()->ClassForTable($d)],
      dbh           => $self->dbh,
      select        => $sql,
      bind_params   => [ $self->setId ],
   )->all_as_hashes;
}

return 1;
