package FlashCards::Controller::sharedsets;

use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::SetOfCards;
use Fey::DBIManager;
use List::MoreUtils qw/any/;

sub sharedsets : Path('/sharedsets') Args {
    my ($self, $c, $page) = @_; 
    $c->forward('FlashCards::Controller::sharedsets', 'common', [$page]);
}

sub common {
    my ($self, $c, $page, $letter) = @_;
    $page = 0 
       if !defined $page;

    $c->user->userId;

    my %args = (
       page    => $page,
       orderBy => 'name',
    );
    $args{name}   = $letter . "%" if any { $_ eq $letter } "a".."z";
    $args{number} = 1             if $letter eq "numbers";

    my @sets = FlashCards::Model::SetOfCards->selectAll(%args)->all;

    $c->stash->{morePages} = 1
       if $c->config->{pageSize} == scalar(@sets);
    $c->stash->{page}     = $page;
    $c->stash->{sets}     = \@sets;
    $c->stash->{template} = 'sharedsets/view.tt';
    $c->stash->{alphabet} = ["a".."z"];
    $c->stash->{currentLetter} = $letter;
}

sub byletter : Path('/sharedsets/byletter') {
    my ($self, $c, $letter, $page) = @_;
    $c->forward('FlashCards::Controller::sharedsets', 'common', [$page, $letter]);
}

1;
