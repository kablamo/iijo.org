package FlashCards::Schema::Result::Definition;
use Moo;
use CEDict::Pinyin;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime FilterColumn/);
__PACKAGE__->table("Definition");
__PACKAGE__->add_columns(
  "definitionId" , { data_type => "integer" , is_nullable => 0 , is_auto_increment => 1 },
  "english"      , { data_type => "varchar" , is_nullable => 0 },
  "simplified"   , { data_type => "varchar" , is_nullable => 1, default_value => \"null" },
  "complex"      , { data_type => "varchar" , is_nullable => 1, default_value => \"null" },
  "pinyin"       , { data_type => "varchar" , is_nullable => 0 },
  "slug"         , { data_type => "varchar" , is_nullable => 0 },
);
__PACKAGE__->filter_column( 
    pinyin => {
        filter_from_storage => sub { CEDict::Pinyin->new($_[1])->diacritic },
    },
);
__PACKAGE__->filter_column( 
    english => {
        filter_from_storage => sub {
            return $_[1] if $_[1] !~ /\//;

            my $rv;
            my $count = 1;
            foreach my $part (split('/', $_[1])) {
                $rv .= "<div id=\"definitionPart\">$count. $part</div>";
                $count++;
            }
            return $rv;
        },
    },
);
__PACKAGE__->set_primary_key("definitionId");
__PACKAGE__->belongs_to(
  "card",
  "FlashCards::Schema::Result::Card",
  { "foreign.definitionId" => "self.definitionId" },
  { cascade_copy => 0, cascade_delete => 1 },
);
__PACKAGE__->belongs_to(
  "setDefinition",
  "FlashCards::Schema::Result::SetDefinition",
  { "foreign.definitionId" => "self.definitionId" },
  { cascade_copy => 0, cascade_delete => 1 },
);

1;
