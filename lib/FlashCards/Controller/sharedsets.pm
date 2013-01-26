package FlashCards::Controller::sharedsets;

use strict;
use warnings;
use base 'Catalyst::Controller';

use FlashCards::Model::SetOfCards;
use Fey::DBIManager;

=head1 NAME

FlashCards::Controller::set - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut


sub sharedsets : Path('/sharedsets') Args {
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
}





=head1 AUTHOR

eric,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
