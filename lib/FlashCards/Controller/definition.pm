package FlashCards::Controller::definition;

use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::SetOfCards;
use FlashCards::Model::Definition;
use Fey::DBIManager;

=head1 NAME

FlashCards::Controller::card - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub view : Path('/definition') Args {
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
sub search: Local Args(0) {
   my ($self, $c) = @_; 
   my $setId    = $c->stash->{setId};
   my $query    = $c->req->params->{search};
   my $language = $c->req->params->{language};

   if (defined $query && defined $language) {
      my $definitions = FlashCards::Model::Definition->search(
         language => $language,
         query    => $query,
         page     => 0,
      );
      my $searchResults = [ $definitions->all_as_hashes ];
      $c->stash->{searchResults}   = $searchResults;
      $c->stash->{definitionQuery} = $query;
      $c->stash->{language}        = $language;
   }

   $c->forward('/set/statbar');
}
#
#
# AM NERVOUS ABOUT LETTING PEOPLE DO THIS.  TURNING IT OFF FOR NOW.
#
#sub editForm : Local {
#   my ($self, $c, $definitionId) = @_; 
#   $c->stash->{definition}  = FlashCards::Model::definition->new(
#      definition_id => $definitionId
#   );
#}
#
#sub edit : Local {
#   my ($self, $c) = @_; 
#
#   my $english       = $c->request->params->{english};
#   my $simplified    = $c->request->params->{simplified};
#   my $complex       = $c->request->params->{complex};
#   my $pinyin        = $c->request->params->{pinyin};
#   my $definitionId  = $c->request->params->{definition_id};
#   my $definition;
#
#   $definition = FlashCards::Model::definition->new(
#      definition_id => $definitionId
#   );
#   $definition->update(
#      english    => $english,
#      simplified => $simplified,
#      complex    => $complex,
#      pinyin     => $pinyin,
#   );
#
#   my $d = $definition->definition_id;
#   $c->res->redirect("/definition/view/$d");
#}

#
# AM NERVOUS ABOUT LETTING PEOPLE DO THIS.  TURNING IT OFF FOR NOW.
#
#sub createForm : Local {
#   my ($self, $c) = @_; 
#}
#
#sub create : Local {
#   my ($self, $c) = @_; 
#
#   my $english     = $c->request->params->{english};
#   my $simplified  = $c->request->params->{simplified};
#   my $complex     = $c->request->params->{complex};
#   my $pinyin      = $c->request->params->{pinyin};
#
#   my $duplicates  = FlashCards::Model::definition->duplicates($simplified);
#   my $count       = scalar(@{$duplicates->remaining()});
#$c->log->info("number of duplicates: " . $count);
#
##   if ($count >= 0) {
##      $c->response->redirect("/definition/view/$d");
##   }
#
#   my $definition = FlashCards::Model::definition->insert(
#      english    => $english,
#      simplified => $simplified,
#      complex    => $complex,
#      pinyin     => $pinyin,
#   );
#
#   my $d = $definition->definition_id;
#   $c->res->redirect("/definition/view/$d");
#}


=head1 AUTHOR

eric,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
