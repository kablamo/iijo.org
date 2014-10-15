package FlashCards::Utils;
use strict;
use warnings;
use DateTime;
use List::AllUtils qw/any/;
use Sys::Hostname;


sub test_mode {
    return 1 if any {$_ eq 'Test/Most.pm'} keys %INC;
    return 0;
}

sub dev_mode {
    return 1 if hostname eq 'eric';
    return 0;
}

# TODO - delete this from here and Networth::Utils.  DateTime defaults to utc
# already.
my $NOW;
sub now { 
    return $NOW->clone if $NOW;
    $NOW = DateTime->now;
    $NOW->set_time_zone('UTC'); 
    return $NOW->clone;
}

sub clearNow { $NOW = undef }

sub newDate {
    my $class = shift;
    my $date = DateTime->new(@_);
    $date->set_time_zone('UTC'); 
    return $date;
}

1;
