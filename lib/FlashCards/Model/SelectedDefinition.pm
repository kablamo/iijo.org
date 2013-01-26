package FlashCards::Model::SelectedDefinition;

use Fey::ORM::Table;
use FlashCards::Model::Schema;
use FlashCards::Model::UserSet;
use MooseX::Params::Validate;
with 'FlashCards::Model';

my $schema = FlashCards::Model::Schema->Schema;
my $us     = $schema->table('UserSet');
my $ld     = $schema->table('SelectedDefinition');
my $sd     = $schema->table('SetDefinition');

has_table $schema->table('SelectedDefinition');
has_one   'set'        => (table => $schema->table('SetOfCards'));
has_one   'definition' => (table => $schema->table('Definition'));
has_one   'user'       => (table => $schema->table('User'));


# by default selected items are the same as the author's selection
# if author has abandoned the set, then just select everything
sub initialize {
   my $self     = shift or die "class param required";
   my %params   = @_;

   die "userSet param is required"   unless defined $params{userSet};
   my $userSet = $params{userSet};

   if ($userSet->userId == $userSet->set->authorId) {
      $self->defaultToEveryWord(userSet => $userSet);
      return undef;
   }

   my $authorSet = FlashCards::Model::UserSet->new(
      userId => $userSet->set->authorId,
      setId  => $userSet->setId,
   );

   if (defined $authorSet) {
      $self->defaultToAuthor(userSet => $userSet);
   }
   else {
      $self->defaultToEveryWord(userSet => $userSet);
   }

   return undef;
}

sub defaultToEveryWord {
   my $self = shift or die;
   my %params = validated_hash(\@_,
      userSet => {isa => 'FlashCards::Model::UserSet', optional => 0},
   );
   my $userSet = $params{userSet};
   my $userId  = $params{userSet}->userId;
   my $dbh     = FlashCards::Model::Schema->DBIManager->default_source->dbh;

   my $sql = "delete from SelectedDefinition where setId = ? and userId = ?";
   my $sth = $dbh->prepare($sql);
   $sth->execute($userSet->setId, $userSet->userId);

   $sql = "
      insert into SelectedDefinition 
            (  setId,   definitionId,  userId)
      select t.setId, t.definitionId, $userId
        from SetDefinition t
       where t.setId = ?
   ";
   $sth = $dbh->prepare($sql);
   $sth->execute($userSet->setId);
}

# returns 1 if successful
# returns 0 if not
sub defaultToAuthor {
   my $self = shift or die;
   my %params = validated_hash(\@_,
      userSet => {isa => 'FlashCards::Model::UserSet', optional => 0},
   );
   my $userSet = $params{userSet};
   my $userId  = $params{userSet}->userId;
   my $dbh     = FlashCards::Model::Schema->DBIManager->default_source->dbh;

   # if user is the author, do nothing
   return 0 if $userSet->userId == $userSet->set->authorId;

   my $sql = "delete from SelectedDefinition where setId = ? and userId = ?";
   my $sth = $dbh->prepare($sql);
   $sth->execute($userSet->setId, $userSet->userId);

   $sql = "
      insert into SelectedDefinition 
            (  setId,   definitionId,  userId)
      select s.setId, s.definitionId, $userId
        from SelectedDefinition s
       where s.setId        = ?
         and s.userId       = ?
   ";
   $sth = $dbh->prepare($sql);
   $sth->execute($userSet->setId, $userSet->set->authorId);

   return 1;
}

# do a regular insert unless the user is the set author.  in that case send changes to all set users.
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
   my $comment      = "--      ";
      $comment      = "        " if $userId != $authorId;

   my $sql = "
      insert into SelectedDefinition 
            (setId,  definitionId, userId)
      select setId, $definitionId, userId
        from UserSet
       where setId  = ?
$comment and userId = ?
      except 
      select ld.setId, ld.definitionId, ld.userId
        from SelectedDefinition ld,
             UserSet us
       where us.userId       = ld.userId
         and us.setId        = ld.setId
         and ld.definitionId = ?
         and ld.setId        = ?
$comment and ld.userId       = ?
   ";
   my $sth = $dbh->prepare($sql);
   my @bindParams = ();
   push(@bindParams, $params{userSet}->setId);
   push(@bindParams, $userId) if $userId != $authorId;
   push(@bindParams, $params{definitionId});
   push(@bindParams, $params{userSet}->setId);
   push(@bindParams, $userId) if $userId != $authorId;
   $sth->execute(@bindParams);

   return undef;
}

sub remove {
   my $self   = shift or die;
   my %params = validated_hash(\@_,
      userSet      => {isa => 'FlashCards::Model::UserSet', optional => 0},
      definitionId => {isa => 'Int',                        optional => 0},
   );
   my $dbh = FlashCards::Model::Schema->DBIManager->default_source->dbh;
   my $userId   = $params{userSet}->userId;
   my $authorId = $params{userSet}->set->authorId;
   my $comment  = "--      ";
      $comment  = "        " if $userId != $authorId;

   my $sql = "
      delete 
        from SelectedDefinition 
       where setId        = ? 
         and definitionId = ?
$comment and userId       = ?
   ";

   my $sth = $dbh->prepare($sql);
   my @bindParams = ();
   push(@bindParams, $params{userSet}->setId);
   push(@bindParams, $params{definitionId});
   push(@bindParams, $userId) if $userId != $authorId;
   $sth->execute(@bindParams);

   return undef;
}

1;
