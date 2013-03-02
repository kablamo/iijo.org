package FlashCards::Model::PopularSets;

use Fey::Table;
use Fey::ORM::Table;
use FlashCards::Model::Schema;
use MooseX::Params::Validate;
with 'FlashCards::Model';

my $schema = FlashCards::Model::Schema->Schema;
my $d      = $schema->table('Definition');
my $sd     = $schema->table('SetDefinition');
my $s      = $schema->table('SetOfCards');
my $us     = $schema->table('UserSet');
my $u      = $schema->table('User');
my $p      = $schema->table('PopularSets');

$p->add_candidate_key($p->column('setId'));

has_table $schema->table('PopularSets');
has_many 'sets'           => (table => $s );
has_many 'userSets'       => (table => $us);
has_one  'setDefinitions' => (table => $sd);

# should put this in a policy
sub selectAll {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      page    => {isa => 'Int', optional => 1, default => 0},
   );
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};

   my $select = $class->SchemaClass->SQLFactoryClass->new_select
          ->select($p)
            ->from($p)
           ->limit($pageSize, $page * $pageSize);

   return Fey::Object::Iterator::FromSelect->new(
      classes     => [ $class->meta->ClassForTable($p) ],
      dbh         => $class->dbh,
      select      => $select,
   );
}

sub selectAllAsUserSets {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      page    => {isa => 'Int', optional => 1, default => 0},
   );
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};

   my $select = $class->SchemaClass->SQLFactoryClass->new_select
          ->select($s)
            ->from($p, $s)
        ->order_by($p->column('users'), 'DESC', $s->column('name'), 'ASC' )
           ->limit($pageSize, $page * $pageSize);

   return Fey::Object::Iterator::FromSelect->new(
      classes     => [ $class->meta->ClassForTable($s) ],
      dbh         => $class->dbh,
      select      => $select,
   );
}

1;
