package FlashCards::Controller::dictionary;

use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::SetOfCards;
use FlashCards::Model::Definition;
use Fey::DBIManager;


sub view : Local Args {
   my ($self, $c, $definitionId, $slug) = @_; 
   my $set;
   my $setId = undef;
      $setId = $_[4] if scalar(@_) == 5;

   my $definition = FlashCards::Model::Definition->new(
      definitionId => $definitionId
   );
   $set = FlashCards::Model::SetOfCards->new(setId => $setId) 
      if defined $setId;

   if (defined $set) {
      $c->stash->{setId}        = $set->setId;
      $c->stash->{setName}      = $set->name;
      $c->stash->{practiceMode} = 1;
   }

   $c->stash->{definition} = $definition;
}

# no validation.  not worried about security here.  there are no updates.
sub search: Path('/dictionary') Args(0) {
   my ($self, $c) = @_; 
$DB::single = 1;
   my $setId    = $c->stash->{setId};
   my $query    = $c->req->params->{query};
   my $language = $c->req->params->{language};

   $c->stash->{template}  = 'dictionary/searchFront.tt';

   if (defined $query && defined $language) {

#      my $best = FlashCards::Model::Definition->bestMatch(
#         language => $language,
#         query    => $query,
#      );
#      my $exact = FlashCards::Model::Definition->firstMatch(
#         language => $language,
#         query    => $query,
#      );
#      my $more = FlashCards::Model::Definition->search(
#         language => $language,
#         query    => $query,
#      );
#      $c->stash->{bestDefinitions}  = [ $best->all_as_hashes ];
#      $c->stash->{exactDefinitions} = [ $exact->all_as_hashes ];
#      $c->stash->{moreDefinitions}  = [ $more->all_as_hashes ];

      my ($best, $exact) = FlashCards::Model::Definition->fancySearch(language => $language, query => $query);
#      my $more = FlashCards::Model::Definition->roughMatch(
#         language => $language,
#         query    => $query,
#         page     => 0,
#      );
      $c->stash->{best}  = $best;
      $c->stash->{exact} = $exact;
#      $c->stash->{more}  = [ $more->all_as_hashes ];

      $c->stash->{query}            = $query;
      $c->stash->{language}         = $language;
      $c->stash->{template}         = 'dictionary/searchResults.tt';
   }
}


1;
