package FlashCards::Schema;
use Moo;
extends 'DBIx::Class::Schema';

use FlashCards::Utils;

__PACKAGE__->load_namespaces(default_resultset_class => 'ResultSet');

my $_schema;
sub schema {
    my ($class) = @_;
    my $db = "flashcards.db";
    $db = "flashcards.db.dev"  if FlashCards::Utils->dev_mode;
    $db = "flashcards.db.test" if FlashCards::Utils->test_mode;
    my $dsn  = "dbi:SQLite:$db";
    my $opts = { quote_names => 1, sqlite_unicode => 1 };
    $_schema //= $class->connect($dsn, '', '', $opts);
}

# FlashCards::Schema->rs('Account');
#   or
# $c->rs('Account');
sub rs {
    my ($class, $rs) = @_;
    $class->schema->resultset($rs);
}

sub trace {
    my ($class, $i) = @_;
    $class->schema->storage->debug( $i || 1 );
}

1;
