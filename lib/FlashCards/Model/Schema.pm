package FlashCards::Model::Schema;

use Fey::DBIManager::Source;
use Fey::Loader;
use Fey::ORM::Schema;
use Moose;
use MooseX::ClassAttribute;
use Sys::Hostname;


my $dbname = 'flashcards.db';
my $dsn    = "dbi:SQLite:dbname=" . $dbname;
my $source = Fey::DBIManager::Source->new(dsn => $dsn);
my $schema = Fey::Loader->new(dbh => $source->dbh)->make_schema();

class_has source => (
    is      => 'ro',
    isa     => 'Fey::DBIManager::Source',
    default => sub { $source },
);

class_has dbh => (
    is      => 'ro',
    default => sub { $source->dbh },
);



# create foreign keys
my @foreignKeys = ();
$foreignKeys[0] = Fey::FK->new(
   source_columns => $schema->table('Definition'   )->column('definitionId'),
   target_columns => $schema->table('Card'         )->column('definitionId'));
$foreignKeys[1] = Fey::FK->new(
   source_columns => $schema->table('Definition'   )->column('definitionId'),
   target_columns => $schema->table('SetDefinition')->column('definitionId'));
$foreignKeys[2] = Fey::FK->new(
   source_columns => $schema->table('SetOfCards'   )->column('setId'),
   target_columns => $schema->table('SetDefinition')->column('setId'));
$foreignKeys[3] = Fey::FK->new(
   source_columns => $schema->table('SetOfCards'   )->column('setId'),
   target_columns => $schema->table('UserSet'      )->column('setId'));
$foreignKeys[4] = Fey::FK->new(
   source_columns => $schema->table('User'         )->column('userId'),
   target_columns => $schema->table('Card'         )->column('userId'));
$foreignKeys[5] = Fey::FK->new(
   source_columns => $schema->table('User'         )->column('userId'),
   target_columns => $schema->table('SetOfCards'   )->column('authorId'));
$foreignKeys[6] = Fey::FK->new(
   source_columns => $schema->table('User'         )->column('userId'),
   target_columns => $schema->table('SetDefinition')->column('authorId'));
$foreignKeys[7] = Fey::FK->new(
   source_columns => $schema->table('User'         )->column('userId'),
   target_columns => $schema->table('UserSet'      )->column('userId'));
$foreignKeys[8] = Fey::FK->new(
   source_columns => $schema->table('User'              )->column('userId'),
   target_columns => $schema->table('SelectedDefinition')->column('userId'));
$foreignKeys[9] = Fey::FK->new(
   source_columns => $schema->table('SetOfCards'        )->column('setId'),
   target_columns => $schema->table('SelectedDefinition')->column('setId'));
$foreignKeys[10] = Fey::FK->new(
   source_columns => $schema->table('Definition'        )->column('definitionId'),
   target_columns => $schema->table('SelectedDefinition')->column('definitionId'));

# add foreign keys
foreach my $key (@foreignKeys) {
   $schema->add_foreign_key($key);
}

has_schema $schema;

__PACKAGE__->DBIManager->add_source($source);
__PACKAGE__->EnableObjectCaches();



1;
