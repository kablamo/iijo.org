package FlashCards::Controller::set;

use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::SetOfCards;
use FlashCards::Model::Definition;
use FlashCards::Model::SelectedDefinition;
use Fey::DBIManager;
use HTML::Scrubber;
use URI::Escape;
use Data::Dumper::Concise;

=head1 NAME

FlashCards::Controller::set - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub create : Local Args {
   my ($self, $c, $error) = @_;

   $c->forward('/getReCaptchaHtml') 
      if $c->user->guest eq 'y';
}

sub createSubmit : Local {
   my ($self, $c) = @_;

   if ($c->user->guest eq 'y') {
      $c->forward('/checkReCaptchaResponse');
      unless ($c->stash->{recaptchaOk}) {
         $c->forward('/set/create');
         $c->stash->{template} = 'set/create.tt';
         $c->detach;
      }
   }

   # validate
   Catalyst::Exception->throw("please enter a name for this set")
      unless (defined $c->req->params->{name} and 
              length($c->req->params->{name}) > 0);
   Catalyst::Exception->throw("please enter a description for this set")
      unless (defined $c->req->params->{description} and 
              length($c->req->params->{description}) > 0);

   my $set = FlashCards::Model::SetOfCards->insert(
      name        => $c->req->params->{name},
      description => $c->req->params->{description},
      authorId    => $c->user->userId,
      slug        => $c->slugify($c->req->params->{name}),
   );
   my $userSet = FlashCards::Model::UserSet->insert(
      userId => $c->user->userId,
      setId  => $set->setId,
   );

   $c->res->redirect("/set/" . $set->setId . "/" . $set->slug);
}

sub statbar : Private {
   my ($self, $c) = @_; 

   my $setId = $c->stash->{setId};

   my $userSet = FlashCards::Model::UserSet->new(
      userId => $c->user->userId,
      setId  => $setId,
   );

   my $set;
   if (!defined $userSet) {
      $set = FlashCards::Model::SetOfCards->new(setId => $setId);
      $c->stash->{cardsLeft}      = 0;
      $c->stash->{completedCards} = 0;
      $c->stash->{totalCards}     = 0;
      $c->stash->{pctComplete}    = 0;
   }
   else {
      $set = $userSet->set;
      $c->stash->{cardsLeft}      = $userSet->cardsLeft;
      $c->stash->{completedCards} = $userSet->completedCards;
      $c->stash->{totalCards}     = $userSet->totalCards;
      $c->stash->{pctComplete}    = $userSet->pctComplete;
   }

   $c->stash->{setId}           = $set->setId;
   $c->stash->{setName}         = $set->name;
   $c->stash->{setSlug}         = $set->slug;
   $c->stash->{description}     = $set->description;
   $c->stash->{users}           = $set->users;
   $c->stash->{author}          = $set->author->username;
   $c->stash->{authorId}        = $set->author->userId;
   $c->stash->{guest}           = $set->author->guest;
   $c->stash->{subtitle}        = $set->name;
}

sub set : Chained('/') CaptureArgs(1) {
   my ($self, $c, $setId, $setName) = @_; 
   $c->stash->{setId}   = $setId;
   $c->stash->{setName} = $setName;
}

sub view : Path('/set') Args {
   my ($self, $c, $setId, $setName, $page) = @_;
   $c->stash->{setId} = $setId;
   $page = 0 unless defined $page;

   my $set = FlashCards::Model::SetOfCards->new(setId => $setId);
   my @definitions = $set->definitions(
      userId  => $c->user->userId,
      page    => $page,
   );

   $c->stash->{morePages} = 1
      if $c->config->{pageSize} == scalar(@definitions);
   $c->stash->{page}        = $page;
   $c->stash->{definitions} = \@definitions;

   $c->forward("/set/statbar");
}

sub ignored : Chained('set') Args {
   my ($self, $c, $page) = @_;
   my $setId = $c->stash->{setId};
   $page = 0 unless defined $page;

   my $set = FlashCards::Model::SetOfCards->new(setId => $setId);
   my @definitions = $set->ignoredDefinitions(
      userId  => $c->user->userId,
      page    => $page,
   );

   $c->stash->{morePages} = 1
      if $c->config->{pageSize} == scalar(@definitions);
   $c->stash->{page}        = $page;
   $c->stash->{definitions} = \@definitions;
   $c->stash->{template}    = 'set/view.tt';
   $c->stash->{cpath}       = 'ignored';

   $c->forward("/set/statbar");
}

sub edit : Chained('set') Args(0) {
   my ($self, $c) = @_;

   # validate
   my $set = FlashCards::Model::SetOfCards->new(setId => $c->stash->{setId});

   $c->user->userId;
   $c->stash->{setId}       = $set->setId;
   $c->stash->{setName}     = $set->name;
   $c->stash->{description} = $set->description;
}


sub editSubmit : Chained('set') Args(0) {
   my ($self, $c) = @_;

# need to worry about spammers and robots here.  recaptcha?

   # validate
   my $set = FlashCards::Model::SetOfCards->new(setId => $c->stash->{setId});
   # validate
   Catalyst::Exception->throw("only set authors can edit set details")
      unless $c->user->userId == $set->authorId;
   # validate
   Catalyst::Exception->throw("please enter a name for this set")
      unless defined $c->req->params->{name};

   $set->update(
      name        => $c->req->params->{name},
      description => $c->req->params->{description},
   );

   $c->res->redirect("/set/" . $set->setId . "/" . uri_escape($set->name));
}

sub selectAll : Chained('set') Args(0) {
   my ($self, $c) = @_; 
   my $setId = $c->stash->{setId};

   my $userSet = FlashCards::Model::UserSet->newOrInsert(
      userId => $c->user->userId,
      setId  => $setId,
   );

   FlashCards::Model::SelectedDefinition->defaultToEveryWord(
      userSet => $userSet,
   );

   $c->res->redirect("/set/$setId/" . uri_escape($userSet->set->name));
}

sub resetSelection : Chained('set') Args(0) {
   my ($self, $c) = @_; 
   my $setId = $c->stash->{setId};

   my $userSet = FlashCards::Model::UserSet->newOrInsert(
      userId => $c->user->userId,
      setId  => $setId,
   );

   my $authorSet = FlashCards::Model::UserSet->new(
      userId => $userSet->set->authorId,
      setId  => $userSet->setId,
   );

   # only do this if author actually uses this set
   FlashCards::Model::SelectedDefinition->defaultToAuthor(
      userSet => $userSet,
   ) if defined $authorSet;

   $c->res->redirect("/set/$setId/" . uri_escape($userSet->set->name));
}

sub search : Chained('set') Args {
   my ($self, $c) = @_; 
   my $setId      = $c->stash->{setId};
   my $page       = 0;

   # no validation.  don't care about security here.  there are no updates.
   my $set = FlashCards::Model::SetOfCards->new(setId  => $setId);

   if (defined $c->req->params->{search}) {
      my @definitions = $set->search(
         column => $c->req->params->{language},
         query  => $c->req->params->{search},
         page   => $page,
      )->all_as_hashes;

      my $morePages = 1 
         if $c->config->{pageSize} == scalar(@definitions);

      $c->stash->{definitions}   = \@definitions;
      $c->stash->{query}         = $c->req->params->{search};
      $c->stash->{language}      = $c->req->params->{language};
      $c->stash->{morePages}     = $morePages;
   }

   $c->stash->{page} = $page;

   $c->forward("/set/statbar");
}

sub add : Chained('set') Args(0) {
   my ($self, $c) = @_; 
   my $setId    = $c->stash->{setId};
   my $query    = $c->req->params->{query};
   my $language = $c->req->params->{language};

   # no validation.  not worried about security here.  there are no updates.

   if (defined $query && defined $language) {
      my ($best, $exact) = FlashCards::Model::Definition->fancySearch(language => $language, query => $query);
      $c->stash->{best}      = $best;
      $c->stash->{exact}     = $exact;
      $c->stash->{query}     = $query;
      $c->stash->{language}  = $language;
   }

   $c->forward('/set/statbar');
}





=head1 AUTHOR

eric,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
