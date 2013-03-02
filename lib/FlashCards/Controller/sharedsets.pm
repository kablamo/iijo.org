package FlashCards::Controller::sharedsets;

use 5.12.0;
use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::SetOfCards;
use FlashCards::Model::PopularSets;
use Fey::DBIManager;
use List::MoreUtils qw/any/;

sub sharedsets : Path('/sharedsets') Args {
    my ($self, $c, $page) = @_; 

    $c->user->userId;

    my @sets = FlashCards::Model::PopularSets
        ->selectAllAsUserSets(page => $page || 0)->all;

    $self->finish($c, \@sets, $page);
}

sub byletter : Path('/sharedsets/byletter') {
    my ($self, $c, $letter, $page) = @_;

    $c->user->userId;

    my %args = (
       page    => $page || 0,
       orderBy => 'name',
    );
    $args{name}   = $letter . "%" if $letter && any { $_ eq $letter } "a".."z";
    $args{number} = 1             if $letter && $letter eq "numbers";

    my @sets = FlashCards::Model::SetOfCards->selectAll(%args)->all;

    $self->finish($c, \@sets, $page);

    $c->stash->{currentLetter} = $letter;
}

sub finish {
    my ($self, $c, $sets, $page) = @_;

    $c->stash->{morePages} = 1 if $c->config->{pageSize} == scalar(@$sets);
    $c->stash->{page}      = $page || 0;
    $c->stash->{sets}      = $sets;
    $c->stash->{alphabet}  = ["a".."z"];
    $c->stash->{template}  = 'sharedsets/view.tt';
}

1;
