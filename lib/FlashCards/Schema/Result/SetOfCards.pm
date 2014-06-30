package FlashCards::Schema::Result::SetOfCards;
use Moo;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime FilterColumn/);
__PACKAGE__->table("SetOfCards");
__PACKAGE__->add_columns(
  "setId"      , { data_type => "integer" , is_auto_increment => 1               , is_nullable => 0 } ,
  "name"       , { data_type => "varchar" , default_value => \"null"             , is_nullable => 1 } ,
  "description", { data_type => "varchar" , default_value => \"null"             , is_nullable => 1 } ,
  "authorId"   , { data_type => "varchar" , is_nullable => 0 }                   ,
  "createDate" , { data_type => "datetime", default_value => \"current_timestamp", is_nullable => 1 , timezone => 'UTC' } ,
  "slug"       , { data_type => "varchar" , default_value => \"null"             , is_nullable => 1 } ,
);
__PACKAGE__->filter_column( description => {
    filter_to_storage   => sub { 
        # TODO - HTML::Scrubber
    },
    filter_from_storage => sub { 
        # TODO - HTML::Scrubber
    }
});
__PACKAGE__->filter_column( name => {
    filter_to_storage   => sub { 
        # TODO - HTML::Scrubber
    },
    filter_from_storage => sub { 
        # TODO - HTML::Scrubber
    }
});
__PACKAGE__->set_primary_key("setId");
__PACKAGE__->belongs_to(
  "author",
  "FlashCards::Schema::Result::User",
  { "foreign.userId" => "self.authorId" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "userSet",
  "FlashCards::Schema::Result::UserSet",
  { "foreign.setId"  => "self.setId",
    "foreign.userId" => "self.authorId" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->has_many(
  "setDefinitions",
  "FlashCards::Schema::Result::SetDefinition",
  { "foreign.setId" => "self.setId" },
  { cascade_copy => 0, cascade_delete => 1 },
);

1;
