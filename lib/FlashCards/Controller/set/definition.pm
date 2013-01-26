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

# anyone can do this
sub add : Chained('definition') Args(0) {
   my ($self, $c) = @_; 
   my $setId        = $c->stash->{setId};
   my $definitionId = $c->stash->{definitionId};

   my $userSet = FlashCards::Model::UserSet->newOrInsert(
      userId => $c->user->userId,
      setId  => $setId,
   );

   my $setDefinition = FlashCards::Model::SetDefinition->add(
      userSet      => $userSet,
      definitionId => $definitionId,
   );

   $c->res->redirect("/set/$setId/" . uri_escape($userSet->set->name));
}

# TODO: if you have > 1000 points, you  can remove any card from any list
sub remove : Chained('definition') Args(0) {
   my ($self, $c) = @_; 
   my $setId        = $c->stash->{setId};
   my $definitionId = $c->stash->{definitionId};

   my $userSet = FlashCards::Model::UserSet->newOrInsert(
      userId => $c->user->userId,
      setId  => $setId,
   );

   # validate
   my $setDefinition = FlashCards::Model::SetDefinition->new(
      setId        => $setId,
      definitionId => $definitionId,
   );
   Catalyst::Exception->throw("you don't have permission to delete this word because you aren't the person who added the word to this set")
      unless $c->user->userId == $setDefinition->authorId;

   $setDefinition->remove(
      userSet      => $userSet,
      definitionId => $definitionId,
   );

   $c->res->redirect("/set/$setId/" . uri_escape($userSet->set->name));
}

# do not check permission.  anyone can do this. even guest users.
sub select : Chained('definition') Args(0) {
   my ($self, $c) = @_; 
   my $setId        = $c->stash->{setId};
   my $definitionId = $c->stash->{definitionId};

   my $userSet = FlashCards::Model::UserSet->newOrInsert(
      userId => $c->user->userId,
      setId  => $setId
   );

   FlashCards::Model::SelectedDefinition->add(
      userSet      => $userSet,
      definitionId => $definitionId,
   );

   $c->res->redirect("/set/$setId/" . uri_escape($userSet->set->name));
}

sub deselect : Chained('definition') Args(1) {
   my ($self, $c, $page) = @_; 
   my $setId        = $c->stash->{setId};
   my $definitionId = $c->stash->{definitionId};

   # validate
   Catalyst::Exception->throw("this page is not permitted: $page")
      unless ($page eq 'view' or $page eq 'ask');

   my $userSet = FlashCards::Model::UserSet->newOrInsert(
      userId => $c->user->userId,
      setId  => $setId,
   );

  FlashCards::Model::SelectedDefinition->remove(
      userSet      => $userSet,
      definitionId => $definitionId,
   );

   if ($page eq 'view') {
      $c->res->redirect("/set/$setId/" . uri_escape($userSet->set->name));
   }
   else {
      $c->res->redirect("/set/$setId/card/$definitionId/ask");
   }
}




=head1 AUTHOR

eric,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
