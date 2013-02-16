package FlashCards::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
   TEMPLATE_EXTENSION => '.tt',
   INCLUDE_PATH       => [
      FlashCards->path_to('root', 'templates'),
      FlashCards->path_to('root', 'static', 'css'),
      FlashCards->path_to('root', 'static', 'js'),
   ],
   TIMER              => FlashCards->config->{'ttTimer'},
   POST_CHOMP         => 1,
   render_die         => 1,
   ENCODING           => 'utf-8',
);

=head1 NAME

FlashCards::View::TT - TT View for FlashCards

=head1 DESCRIPTION

TT View for FlashCards. 

=head1 AUTHOR

=head1 SEE ALSO

L<FlashCards>

eric,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
