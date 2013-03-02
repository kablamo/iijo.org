package FlashCards::Controller::mysets::card;

use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::Card;
use FlashCards::Model::Definition;
use FlashCards::Model::SetOfCards;
use Fey::DBIManager;
use DateTime;

sub card : Chained('../mysets') CaptureArgs(1) {
   my ($self, $c, $cardId) = @_; 
   $c->stash->{cardId} = $cardId;
}

# get the next card 
sub ask : Chained('card') Args {
   my ($self, $c, $JSON) = @_; 
   my $prevDefinitionId = 0;
   $prevDefinitionId = $c->stash->{cardId}
      if defined $c->stash->{cardId};

   my $card = $c->user->ask(
      userId       => $c->user->userId,
      definitionId => $prevDefinitionId,
   );
   if (!defined $card) {
      if (defined $JSON and $JSON = 'json') {
         $c->stash->{current_view}  = 'JSON';
      }
      else {
         $c->response->redirect("/mysets/card/done");
      }
      $c->detach;
   }

   $c->stash->{practiceMode} = 1;
   $c->stash->{baseURL}      = '/mysets/card/';
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
      if (defined $JSON and $JSON eq 'json');

   $c->forward('/mysets/statbar');
}

# not validating.  don't care about security here.  no updates being made.
sub answer : Chained('card') Args {
   my ($self, $c) = @_; 

   $c->user->userId,
   my $card = FlashCards::Model::Card->new(cardId => $c->stash->{cardId});

   $c->stash->{practiceMode} = 1;
   $c->stash->{baseURL}      = '/mysets/card/';
   $c->stash->{difficulty}   = $card->delayExponent;
   $c->stash->{definitionId} = $card->definitionId;
   $c->stash->{cardId}       = $card->cardId;

   $c->stash->{english}      = $card->definition->english;
   $c->stash->{pinyin}       = $card->definition->pinyin;
   $c->stash->{simplified}   = $card->definition->simplified;

   $c->stash->{template}     = 'card/answer.tt';

   $c->forward('/mysets/statbar');
}

sub difficulty : Chained('card') Args {
   my ($self, $c, $correct) = @_; 

   # validate
   my $card = FlashCards::Model::Card->new(cardId => $c->stash->{cardId});

   # validate
   Catalyst::Exception->throw("this isn't your card")
      unless $c->user->userId == $card->userId;

   $c->stash->{card} = $card;
   $c->forward('/updateCard', $correct);

   my $definitionId = $card->definitionId;
   $c->res->redirect("/mysets/card/$definitionId/ask" );
}

# not validating.  don't care about security here.  no updates being made.
sub done : Local {
   my ($self, $c) = @_; 
   $c->user->userId,
   $c->stash->{practiceMode} = 1;
   $c->stash->{allCards}     = 1;
   $c->stash->{template}     = 'card/done.tt';
   $c->forward('/mysets/statbar');
}

1;
