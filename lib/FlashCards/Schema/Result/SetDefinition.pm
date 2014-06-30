package FlashCards::Schema::Result::SetDefinition;
use Moo;
extends 'DBIx::Class::Core';

__PACKAGE__->table("SetDefinition");
__PACKAGE__->add_columns(
  "setId"        , { data_type => "integer" , is_nullable => 0 , is_auto_increment => 1 },
  "definitionId" , { data_type => "integer" , is_nullable => 0 },
  "authorId"     , { data_type => "integer" , is_nullable => 0 },
);
__PACKAGE__->set_primary_key("setId");
__PACKAGE__->has_one(
  "definition",
  "FlashCards::Schema::Result::Definition",
  { "foreign.definitionId" => "self.definitionId" },
  { cascade_copy => 0, cascade_delete => 1 },
);
__PACKAGE__->belongs_to(
  "author",
  "FlashCards::Schema::Result::User",
  { "foreign.userId" => "self.authorId" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

1;
