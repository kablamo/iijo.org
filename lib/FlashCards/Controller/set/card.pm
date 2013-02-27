package FlashCards::Controller::set::card;

use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::Card;
use FlashCards::Model::Definition;
use FlashCards::Model::SetOfCards;
use Fey::DBIManager;
use DateTime;

=head1 NAME

FlashCards::Controller::set::card - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub card : Chained('../set') CaptureArgs(1) {
   my ($self, $c, $cardId) = @_; 
   $c->stash->{cardId} = $cardId;
}

# get the next card 
sub ask : Chained('card') Args {
   my ($self, $c, $JSON) = @_; 
   my $setId = $c->stash->{setId};
   my $prevDefinitionId = 0;
   $prevDefinitionId = $c->stash->{cardId}
      if defined $c->stash->{cardId};

   # validate
   my $set = FlashCards::Model::SetOfCards->new(setId => $c->stash->{setId});

   my $userSet = FlashCards::Model::UserSet->new(
      userId => $c->user->userId,
      setId  => $c->stash->{setId},
   );

   my $card = FlashCards::Model::Card->ask(
      userId       => $c->user->userId,
      setId        => $c->stash->{setId},
      definitionId => $prevDefinitionId,
   );
   if (!defined $card) {
      if (defined $JSON and $JSON = 'json') {
         $c->stash->{current_view} = 'JSON';
      }
      else {
         $c->response->redirect("/set/$setId/card/done");
      }
      $c->detach;
   }

   $c->stash->{practiceMode} = 1;
   $c->stash->{baseURL}      = "/set/$setId/card/";
   $c->stash->{difficulty}   = $card->delayExponent;
   $c->stash->{definitionId} = $card->definitionId;
   $c->stash->{cardId}       = $card->cardId;

   $c->stash->{english}    = '&nbsp;';
   $c->stash->{pinyin}     = '&nbsp;';
   $c->stash->{simplified} = '&nbsp;';

   my $q = $card->question;
   my $d = $card->definition;
   $c->stash->{english}    = $d->english    if $q eq 'english';
   $c->stash->{pinyin}     = $d->pinyin     if $q eq 'pinyin';
   $c->stash->{simplified} = $d->simplified if $q eq 'simplified';

   $c->stash->{englishAnswer}    = $d->english;
   $c->stash->{pinyinAnswer}     = $d->pinyin;
   $c->stash->{simplifiedAnswer} = $d->simplified;

   $c->stash->{template}      = 'card/ask.tt';
   $c->stash->{current_view}  = 'JSON' 
      if (defined $JSON and $JSON = 'json');

   $c->forward('/set/statbar');
}

# not validating.  don't care about security here.  no updates being made.
sub answer : Chained('card') Args {
   my ($self, $c) = @_; 
   my $setId = $c->stash->{setId};

   $c->user->userId,
   my $card = FlashCards::Model::Card->new(cardId => $c->stash->{cardId});

   $c->stash->{practiceMode} = 1;
   $c->stash->{baseURL}      = "/set/$setId/card/";
   $c->stash->{difficulty}   = $card->delayExponent;
   $c->stash->{definitionId} = $card->definitionId;
   $c->stash->{cardId}       = $card->cardId;

   $c->stash->{english}      = $card->definition->english;
   $c->stash->{pinyin}       = $card->definition->pinyin;
   $c->stash->{simplified}   = $card->definition->simplified;

   $c->stash->{template}     = 'card/answer.tt';

   $c->forward('/set/statbar');
}

sub difficulty : Chained('card') Args {
   my ($self, $c, $correct) = @_; 
   my $setId   = $c->stash->{setId};

   # validate
   my $userSet = FlashCards::Model::UserSet->new(
      userId => $c->user->userId,
      setId  => $c->stash->{setId},
   );
   # validate
   my $card = FlashCards::Model::Card->new(cardId => $c->stash->{cardId});

   $c->stash->{card} = $card;
   $c->forward('/updateCard', $correct);


   my $definitionId = $card->definitionId;
   $c->res->redirect("/set/$setId/card/$definitionId/ask" );
}

# not validating.  don't care about security here.  no updates being made.
sub done : PathPart('card/done') Chained('../set') Args(0) {
   my ($self, $c) = @_; 
   $c->user->userId,
   $c->stash->{practiceMode} = 1;
   $c->stash->{template}     = 'card/done.tt';
   $c->forward('/set/statbar');
}



=head1 AUTHOR

eric,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
