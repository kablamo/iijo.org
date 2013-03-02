package FlashCards::Controller::sharedsets;

use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::SetOfCards;
use Fey::DBIManager;

sub sharedsets : Path('/sharedsets') Args {
   my ($self, $c, $page) = @_; 
   $c->forward('FlashCards::Controller::sharedsets', 'common', [$page]);
}

sub common {
    my ($self, $c, $page) = @_;
    $page = 0 
       if !defined $page;

    $c->user->userId;
    my @sets = FlashCards::Model::SetOfCards->selectAll(
       page    => $page,
       orderBy => 'name',
    )->all;

    $c->stash->{morePages} = 1
       if $c->config->{pageSize} == scalar(@sets);
    $c->stash->{page}     = $page;
    $c->stash->{sets}     = \@sets;
    $c->stash->{template} = 'sharedsets/view.tt';
    $c->stash->{alphabet} = ["a".."z"];
}

1;
