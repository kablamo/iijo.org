package FlashCards::Model::Definition;

use CEDict::Pinyin;
use FlashCards::Model::Schema;
use Fey::Object::Iterator::FromSelect;
use Fey::ORM::Table;
use Fey::Placeholder;
use Fey::SQL;
use MooseX::Params::Validate;
use Time::HiRes qw(gettimeofday tv_interval);
with 'FlashCards::Model';


has_table(FlashCards::Model::Schema->Schema->table('Definition'));


transform 'pinyin'
   => inflate { defined $_[1]? CEDict::Pinyin->new($_[1])->diacritic() :undef;  }
   => deflate { defined $_[1]? $_[1] :undef; };

transform 'english'
   => inflate { 
         return undef if !defined $_[1];
         return $_[1] if $_[1] !~ /\//;
         
         my $rv;
         my $count = 1;
         foreach my $part (split('/', $_[1])) {
            $rv .= "<div id=\"definitionPart\">$count. $part</div>";
            $count++;
         }
         return $rv;
};

# search everything except an exact match
sub bestMatch {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      language      => {isa => 'Str', optional => 0},
      query         => {isa => 'Str', optional => 0},
   );
   my $language = $params{language};
   my $query    = $params{query};

   my $definition = $class->SchemaClass()->Schema()->table('Definition');
   my $select     = $class->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($definition)
            ->from($definition)
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('(')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where(')');

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $class->meta()->ClassForTable($definition) ],
      dbh         => $class->dbh,
      select      => $select,
      bind_params => [       '%CL:%',
                              $query, 
                       '%/' . $query . '/%',
                       '%/' . $query, 
                              $query . '/%', 
                              'to ' . $query, 
                       '%/' . 'to ' . $query . '/%',
                       '%/' . 'to ' . $query, 
                              'to ' . $query . '/%', 
                     ],
   );
}

# search for an exact match only
sub firstMatch {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      language      => {isa => 'Str', optional => 0},
      query         => {isa => 'Str', optional => 0},
   );
   my $language = $params{language};
   my $query    = $params{query};

   my $definition = $class->SchemaClass()->Schema()->table('Definition');
   my $sql        = $class->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($definition)
            ->from($definition)
           ->where('(')
           ->where($definition->column($language), 'like',     Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like',     Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like',     Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like',     Fey::Placeholder->new())
           ->where(')')
           ->where($definition->column($language), 'not like', Fey::Placeholder->new())
        ->order_by($definition->column($language));

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $class->meta()->ClassForTable($definition) ],
      dbh         => $class->dbh,
      select      => $sql,
      bind_params => ['to ' . $query,
                      $query, 
                      'to ' . $query . '/%',
                      $query . '/%', 
                      '%CL:%'
                     ],
   );
}

# search for an exact match only
sub otherMatch {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      language      => {isa => 'Str', optional => 0},
      query         => {isa => 'Str', optional => 0},
   );
   my $language = $params{language};
   my $query    = $params{query};

   my $definition = $class->SchemaClass()->Schema()->table('Definition');
   my $sql        = $class->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($definition)
            ->from($definition)
           ->where('(')
           ->where($definition->column($language), 'like',     Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like',     Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like',     Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like',     Fey::Placeholder->new())
           ->where(')')
           ->where($definition->column($language), 'not like', Fey::Placeholder->new())
           ->where($definition->column($language), 'not like', Fey::Placeholder->new())
           ->where($definition->column($language), 'not like', Fey::Placeholder->new())
           ->where($definition->column($language), 'not like', Fey::Placeholder->new())
           ->where($definition->column($language), 'not like', Fey::Placeholder->new());

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $class->meta()->ClassForTable($definition) ],
      dbh         => $class->dbh,
      select      => $sql,
      bind_params => ['%/' . $query . '/%',
                      '%/' . $query, 
                      '%/' . 'to ' . $query . '/%',
                      '%/' . 'to ' . $query, 
                      $query, 
                      'to ' . $query, 
                      $query . '/%', 
                      'to ' . $query . '/%', 
                      '%CL:%', 
                     ],
   );
}

sub roughMatch {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      language      => {isa => 'Str', optional => 0},
      query         => {isa => 'Str', optional => 0},
      page          => {isa => 'Int', optional => 1, default => 0},
   );
   my $language = $params{language};
   my $query    = $params{query};
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};

   my $definition = $class->SchemaClass()->Schema()->table('Definition');
   my $yes = $class->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($definition)
            ->from($definition)
           ->where($definition->column($language), 'like', Fey::Placeholder->new());

   my $no = $class->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($definition)
            ->from($definition)
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new());

   my $sql = $class->SchemaClass()->SQLFactoryClass()->new_except()
         ->except($yes, $no)
          ->limit($pageSize, $page * $pageSize);

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $class->meta()->ClassForTable($definition) ],
      dbh         => $class->dbh,
      select      => $sql,
      bind_params => [  '%' . $query . '%', 
                              $query,
                       '%/' . $query . '/%',
                       '%/' . $query, 
                              $query . '/%', 
                              'to ' . $query,
                       '%/' . 'to ' . $query . '/%',
                       '%/' . 'to ' . $query, 
                              'to ' . $query . '/%', 
                     ],
   );
}

sub fancySearch {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      language      => {isa => 'Str', optional => 0},
      query         => {isa => 'Str', optional => 0},
      page          => {isa => 'Int', optional => 1, default => 0},
   );

   my @best  = $class->bestMatch(@_)->all_as_hashes;
   my @first = $class->firstMatch(@_)->all_as_hashes;
   my @more  = $class->otherMatch(@_)->all_as_hashes;

   my $bestCount  = scalar(@best);
   my $firstCount = scalar(@first);
   my $moreCount  = scalar(@more);

   return (\@best, [@first, @more]) if scalar(@best ) > 0;
   return (\@first, \@more)         if scalar(@first) > 0;
   return \@more;
}

# this method should go away.  it should be replaced by ... something
sub search {
   my $class  = shift or die;
   my %params = validated_hash(\@_,
      language      => {isa => 'Str', optional => 0},
      query         => {isa => 'Str', optional => 0},
      page          => {isa => 'Int', optional => 1, default => 0},
   );
   my $language = $params{language};
   my $query    = $params{query};
   my $page     = $params{page};
   my $pageSize = FlashCards->config->{pageSize};

   my $definition = $class->SchemaClass()->Schema()->table('Definition');
   my $select     = $class->SchemaClass()->SQLFactoryClass()->new_select()
          ->select($definition)
            ->from($definition)
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->where('or')
           ->where($definition->column($language), 'like', Fey::Placeholder->new())
           ->limit($pageSize, $page * $pageSize);

   return Fey::Object::Iterator::FromSelect->new ( 
      classes     => [ $class->meta()->ClassForTable($definition) ],
      dbh         => $class->dbh,
      select      => $select,
      bind_params => [        $query, 
                       '%/' . $query . '/%',
                       '%/' . $query, 
                              $query . '/%', 
                     ],
   );
}




1;
