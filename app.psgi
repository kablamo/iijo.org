use strict;
use warnings;

use FlashCards;

my $app = FlashCards->apply_default_middlewares(FlashCards->psgi_app);
$app;

