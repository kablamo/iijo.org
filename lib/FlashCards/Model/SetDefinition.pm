package FlashCards::Model::SetDefinition;

use Fey::ORM::Table;
use FlashCards::Model::Card;
use FlashCards::Model::Schema;
use FlashCards::Model::SetDefinition;
use FlashCards::Model::SelectedDefinition;
use MooseX::Params::Validate;
with 'FlashCards::Model';


my $schema = FlashCards::Model::Schema->Schema;
has_table $schema->table('SetDefinition');
has_one   'set'        => (table => $schema->table('SetOfCards'));
has_one   'definition' => (table => $schema->table('Definition'));
has_one   'author'     => (table => $schema->table('User'));

has 'selected' => (
   is      => 'rw',
   isa     => 'Int',
   default => 1,
);

has 'disabled' => (
   is      => 'rw',
   isa     => 'Int',
   default => 1,
);

sub add {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      definitionId  => {isa => 'Int', optional => 0},
      userSet       => {isa => 'FlashCards::Model::UserSet', optional => 0},
   );

   my $setDefinition = FlashCards::Model::SetDefinition->insert(
      setId        => $params{userSet}->setId,
      definitionId => $params{definitionId},
      authorId     => $params{userSet}->userId,
   );

   FlashCards::Model::SelectedDefinition->add(
      userSet      => $params{userSet},
      definitionId => $params{definitionId},
   );

   FlashCards::Model::Card->add(
      userSet      => $params{userSet},
      definitionId => $params{definitionId},
      
   );
}

sub remove {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      definitionId  => {isa => 'Int', optional => 0},
      userSet       => {isa => 'FlashCards::Model::UserSet', optional => 0},
   );

   my $setDefinition = FlashCards::Model::SetDefinition->new(
      setId        => $params{userSet}->setId,
      definitionId => $params{definitionId},
   );
   $setDefinition->delete;

   my $selectedDefinition = FlashCards::Model::SelectedDefinition->new(
      setId        => $params{userSet}->setId,
      definitionId => $params{definitionId},
      userId       => $params{userSet}->userId,
   );
   $selectedDefinition->delete if defined $selectedDefinition;

   # never delete from the Card table.  
}


1;
