package FlashCards::Controller::set::definition;

use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::Card;
use FlashCards::Model::Definition;
use FlashCards::Model::SetOfCards;
use Fey::DBIManager;
use DateTime;
use Data::TreeDumper;
use URI::Escape;

=head1 NAME

FlashCards::Controller::card - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub definition : Chained('../set') CaptureArgs(1) {
   my ($self, $c, $definitionId) = @_; 

   # validate definitionId
   my $definition = FlashCards::Model::Definition->new(
      definitionId => $definitionId,
   );
   Catalyst::Exception->throw("that definitionId doesn't exist")
      unless defined $definition;

   $c->stash->{definitionId} = $definitionId;
}

# only the set owner has permission to add definitions
sub add : Chained('definition') Args(0) {
   my ($self, $c) = @_; 
   my $setId        = $c->stash->{setId};
   my $definitionId = $c->stash->{definitionId};

   my $userSet = FlashCards::Model::UserSet->new(
      userId => $c->user->userId,
      setId  => $setId,
   );

   my $setDefinition = FlashCards::Model::SetDefinition->add(
      userSet      => $userSet,
      definitionId => $definitionId,
   );

   $c->res->redirect("/set/$setId/" . uri_escape($userSet->set->name));
}

# only the set owner has permission to remove definitions
sub remove : Chained('definition') Args(0) {
   my ($self, $c) = @_; 
   my $setId        = $c->stash->{setId};
   my $definitionId = $c->stash->{definitionId};

   my $userSet = FlashCards::Model::UserSet->new(
      userId => $c->user->userId,
      setId  => $setId,
   );

   # validate
   my $setDefinition = FlashCards::Model::SetDefinition->new(
      setId        => $setId,
      definitionId => $definitionId,
   );
   Catalyst::Exception->throw("you don't have permission to delete this word because you aren't the set owner")
      unless $c->user->userId == $setDefinition->authorId;

   $setDefinition->remove(
      userSet      => $userSet,
      definitionId => $definitionId,
   );

   $c->res->redirect("/set/$setId/" . uri_escape($userSet->set->name));
}

=head1 AUTHOR

eric,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
