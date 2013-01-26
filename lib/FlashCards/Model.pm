package FlashCards::Model;

use FlashCards::Model::Schema;
use Moose::Role;
use MooseX::ClassAttribute;

class_has dbh => (
    is      => 'rw',
    default => sub { FlashCards::Model::Schema->dbh },
);

1;
