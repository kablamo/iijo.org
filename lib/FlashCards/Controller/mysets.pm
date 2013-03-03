package FlashCards::Controller::mysets;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Data::TreeDumper;
use Fey::DBIManager;
use FlashCards::Model::User;
use DateTime;
$|=1;

=head1 NAME

FlashCards::Controller::mysets - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub statbar : Private {
   my ($self, $c) = @_; 

   my $user = $c->user;

   $c->stash->{cardsLeft}      = $user->cardsLeft;
   $c->stash->{completedCards} = $user->completedCards;
   $c->stash->{totalCards}     = $user->totalCards;
   $c->stash->{pctComplete}    = $user->pctComplete;
}

sub mysets : Chained('/') CaptureArgs(0) {}

sub view : Path('/mysets') Args {
   my ($self, $c, $page) = @_; 
   $page = 0 
      if !defined $page;

   my @userSets = FlashCards::Model::UserSet->selectMany(
      userId => $c->user->userId,
      page   => $page,
   )->all;

   $c->stash->{morePages} = 1
      if $c->config->{pageSize} == scalar(@userSets);
   $c->stash->{userSets}  = \@userSets;
   $c->stash->{page}      = $page;
   $c->stash->{template}  = 'mysets/view.tt';

   $c->forward('/mysets/statbar');
}

sub delete : Local {
   my ($self, $c, $setId) = @_;

   my $userSet = FlashCards::Model::UserSet->new(
      setId    => $setId,
      userId   => $c->user->userId,
   );
   Catalyst::Exception->throw('You cannot delete a set unless you use it and it shows up on your "My sets" page.')
      if !defined $userSet;

   my $set = $userSet->set;
   if ($set->users == 1 and $set->authorId == $c->user->userId) {
      my @setDefinitions = $set->setDefinitions->all;
      $_->delete foreach (@setDefinitions);
      $set->delete;
   }

   $userSet->delete;

   $c->res->redirect("/mysets");
}


=head1 AUTHOR

eric,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
