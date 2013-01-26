#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/say/;

use Authen::Passphrase::BlowfishCrypt;
use DBI;
use Data::Dumper::Concise;


my $dbh = DBI->connect("dbi:SQLite:dbname=flashcards.db",'','');

my $update = "update user set password = ? where username = ?";
my $select = 'select username, password from user where password is not null and password not like "%{CRYPT}$2a$12$%"';
my $result = $dbh->selectall_arrayref($select, {Slice => {}});

my $sth = $dbh->prepare($update);
foreach my $row (@$result) {
    my $blowfish = Authen::Passphrase::BlowfishCrypt->new(
       passphrase  => $row->{password},
       salt_random => 1,
       cost        => 12,
    );
    say 'username: ' . $row->{username} . ', password: ' . $row->{password} . ', new: ' . $blowfish->as_rfc2307;
    $sth->bind_param(1, $blowfish->as_rfc2307);
    $sth->bind_param(2, $row->{username});
    $sth->execute or die;

}
