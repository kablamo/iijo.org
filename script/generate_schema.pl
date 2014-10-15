#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/say/;

use DateTime;
use FlashCards::Schema;

my $schema = FlashCards::Schema->schema;

my $sql_dir = './schema';

my $version = DateTime->now;
$schema->create_ddl_dir( 'SQLite', "$version", "./schema" );
