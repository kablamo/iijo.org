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
my $ld     = $schema->table('SelectedDefinition');
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



# should put this in a policy
sub selectAll {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      page    => {isa => 'Int', optional => 1, default => 0},
      orderBy => {              optional => 1, default => 'name'},
   );
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};
   my $orderBy  = $params{orderBy};

   my $select = $class->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($s)
            ->from($s)
           ->limit($pageSize, $page * $pageSize)
        ->order_by($s->column($orderBy));

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $class->meta()->ClassForTable($s) ],
      dbh         => $class->dbh,
      select      => $select,
   );
}

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

# I'm not using 'has_many setDefinitions' because there is no way to do paging
# and worse it would be much slower since it requires 1 query for each
# definition.  Also I want more info than that one table can give me.
sub userDefinitionsMain {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      userId        => {isa => 'Int', optional => 0},
      page          => {isa => 'Int', optional => 1, default => 0},
   );
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};

   my $selected = $self->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($sd, $d, $u)
            ->from($sd, $d)
            ->from($ld, $d)
            ->from($sd, $u)
           ->where($ld->column('setId'),        '=', $sd->column('setId'))
           ->where($ld->column('definitionId'), '=', $sd->column('definitionId'))
           ->where($sd->column('authorId'),     '=', $u->column('userId'))
           ->where($ld->column('setId'),        '=', Fey::Placeholder->new())
           ->where($ld->column('userId'),       '=', Fey::Placeholder->new());

   my $allDefinitions = $self->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($sd, $d, $u)
            ->from($sd, $d)
            ->from($sd, $u)
           ->where($sd->column('authorId'), '=', $u->column('userId')) 
           ->where($sd->column('setId'),    '=', Fey::Placeholder->new());

   my $selectedDefinitions = $self->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($sd, $d, $u)
            ->from($sd, $d)
            ->from($ld, $d)
            ->from($sd, $u)
           ->where($ld->column('setId'),        '=', $sd->column('setId'))
           ->where($ld->column('definitionId'), '=', $sd->column('definitionId'))
           ->where($sd->column('userId'),       '=', $u->column('userId'))
           ->where($ld->column('setId'),        '=', Fey::Placeholder->new())
           ->where($ld->column('userId'),       '=', Fey::Placeholder->new());

   my $unselected = $self->SchemaClass()->SQLFactoryClass()->new_except()
         ->except($allDefinitions, $selectedDefinitions);

   my $sql = $self->SchemaClass()->SQLFactoryClass()->new_union()
         ->union($selected, $unselected)
           ->limit($pageSize, $page * $pageSize)
        ->order_by($d->column('simplified'));

   return Fey::Object::Iterator::FromSelect->new(
      classes       => [ 
         $self->meta()->ClassForTable($sd),
         $self->meta()->ClassForTable($d), 
         $self->meta()->ClassForTable($u) 
      ],
      dbh           => $self->dbh,
      select        => $sql,
      bind_params   => [ 
         $self->setId, 
         $params{userId}, 
         $self->setId, 
         $self->setId, 
         $params{userId},
      ],
   )->all_as_hashes;
}

sub _definitions {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      findUserId  => {isa => 'Int', optional => 0},
      userId      => {isa => 'Int', optional => 0},
      page        => {isa => 'Int', optional => 1, default => 0},
   );
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};

   my $sql = $self->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($sd, $d, $u)
            ->from($sd, $d)
            ->from($ld, $d)
            ->from($sd, $u)
           ->where($ld->column('setId'),        '=', $sd->column('setId'))
           ->where($ld->column('definitionId'), '=', $sd->column('definitionId'))
           ->where($sd->column('authorId'),     '=', $u->column('userId'))
           ->where($ld->column('setId'),        '=', Fey::Placeholder->new())
           ->where($ld->column('userId'),       '=', Fey::Placeholder->new())
           ->limit($pageSize, $page * $pageSize)
        ->order_by($d->column('simplified'));

   my @definitions = Fey::Object::Iterator::FromSelect->new(
      classes       => [ 
         $self->meta()->ClassForTable($sd),
         $self->meta()->ClassForTable($d), 
         $self->meta()->ClassForTable($u) 
      ],
      dbh           => $self->dbh,
      select        => $sql,
      bind_params   => [ $self->setId, $params{findUserId} ],
   )->all_as_hashes;

   foreach my $d (@definitions) {
      $d->{SetDefinition}->{disabled} = 1; 
      $d->{SetDefinition}->{disabled} = 0 
         if $params{userId} eq $d->{SetDefinition}->{authorId};
   }

   return @definitions;
}

sub _ignoredDefinitions {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      findUserId  => {isa => 'Int', optional => 0},
      userId      => {isa => 'Int', optional => 0},
      page        => {isa => 'Int', optional => 1, default => 0},
   );
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};

   my $all = $self->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($sd, $d, $u)
            ->from($sd, $d)
            ->from($sd, $u)
           ->where($sd->column('authorId'), '=', $u->column('userId')) 
           ->where($sd->column('setId'),    '=', Fey::Placeholder->new());

   my $selected = $self->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($sd, $d, $u)
            ->from($sd, $d)
            ->from($ld, $d)
            ->from($sd, $u)
           ->where($ld->column('setId'),        '=', $sd->column('setId'))
           ->where($ld->column('definitionId'), '=', $sd->column('definitionId'))
           ->where($sd->column('authorId'),     '=', $u->column('userId'))
           ->where($ld->column('setId'),        '=', Fey::Placeholder->new())
           ->where($ld->column('userId'),       '=', Fey::Placeholder->new());

   my $sql = $self->SchemaClass()->SQLFactoryClass()->new_except()
          ->except($all, $selected)
           ->limit($pageSize, $page * $pageSize)
        ->order_by($d->column('simplified'));

   my @ignoredDefinitions = Fey::Object::Iterator::FromSelect->new(
      classes       => [ 
         $self->meta()->ClassForTable($sd),
         $self->meta()->ClassForTable($d), 
         $self->meta()->ClassForTable($u) 
      ],
      dbh           => $self->dbh,
      select        => $sql,
      bind_params   => [ 
         $self->setId, 
         $self->setId, 
         $params{findUserId},
      ],
   )->all_as_hashes;

   foreach my $d (@ignoredDefinitions) {
      $d->{SetDefinition}->{selected} = 0; 
      $d->{SetDefinition}->{disabled} = 1; 
      $d->{SetDefinition}->{disabled} = 0 
         if $params{userId} eq $d->{SetDefinition}->{authorId};
   }

   return @ignoredDefinitions;
}

sub allDefinitions {
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

sub definitions {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      userId  => {isa => 'Int', optional => 0},
      page    => {isa => 'Int', optional => 1, default => 0},
   );
   my $page = $params{page};

   $params{userId} == $self->authorId 
   || defined FlashCards::Model::UserSet->new(
         userId => $params{userId},
         setId  => $self->setId,
   ) 
   && return $self->_definitions(
         findUserId => $params{userId},
         userId     => $params{userId},
         page       => $params{page},
   );

   defined FlashCards::Model::UserSet->new(
         userId => $self->authorId,
         setId  => $self->setId,
   )
   && return $self->_definitions(
         findUserId => $self->authorId,
         userId     => $params{userId},
         page       => $params{page},
   );

   return $self->allDefinitions(page => $page);
}

sub ignoredDefinitions {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      userId  => {isa => 'Int', optional => 0},
      page    => {isa => 'Int', optional => 1, default => 0},
   );
   my $page = $params{page};

   $params{userId} == $self->authorId 
   || defined FlashCards::Model::UserSet->new(
         userId => $params{userId},
         setId  => $self->setId,
   )
   && return $self->_ignoredDefinitions(
         findUserId => $params{userId},
         userId     => $params{userId},
         page       => $params{page},
   );

   defined FlashCards::Model::UserSet->new(
         userId => $self->authorId,
         setId  => $self->setId,
      )
   && return $self->_ignoredDefinitions(
         findUserId => $self->authorId,
         userId     => $params{userId},
         page       => $params{page},
   );
   
   return ();
}

return 1;
