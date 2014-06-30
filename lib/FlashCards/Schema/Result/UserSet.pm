package FlashCards::Schema::Result::UserSet;
use Moo;
extends 'DBIx::Class::Core';

__PACKAGE__->table("UserSet");
__PACKAGE__->add_columns(
  "userId"     , { data_type => "integer" , is_auto_increment => 1   , is_nullable => 0 } ,
  "setId"      , { data_type => "integer" , default_value => \"null" , is_nullable => 0 } ,
);
__PACKAGE__->set_primary_key("userId");
__PACKAGE__->add_unique_constraint("setid_unique", ["setId"]);
__PACKAGE__->belongs_to(
  "user",
  "FlashCards::Schema::Result::User",
  { "foreign.userId" => "self.userId" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->has_one(
  "setOfCards",
  "FlashCards::Schema::Result::SetOfCards",
  { "foreign.authorId" => "self.userId",
    "foreign.setId"    => "self.setId" },
  { cascade_copy => 0, cascade_delete => 1 },
);

1;
