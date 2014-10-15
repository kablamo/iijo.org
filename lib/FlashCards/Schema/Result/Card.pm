package FlashCards::Schema::Result::Card;
use Moo;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);
__PACKAGE__->table("Card");
__PACKAGE__->add_columns(
  "cardId"       , { data_type => "integer" , is_nullable => 0 , is_auto_increment => 1 } ,
  "userId"       , { data_type => "integer" , is_nullable => 0 },
  "definitionId" , { data_type => "integer" , is_nullable => 0 },
  "question"     , { data_type => "varchar" , is_nullable => 0 },
  "startDate"    , { data_type => "datetime", is_nullable => 0 ,                                        timezone => 'UTC' },
  "lastDate"     , { data_type => "datetime", is_nullable => 1 , default_value => \"current_timestamp", timezone => 'UTC' },
  "nextDate"     , { data_type => "datetime", is_nullable => 1 , default_value => \"current_timestamp", timezone => 'UTC' },
  "lastAnswer"   , { data_type => "varchar" , is_nullable => 1 , default_value => \"null" },
  "delayExponent", { data_type => "integer" , is_nullable => 0 },
);
__PACKAGE__->set_primary_key("cardId");
__PACKAGE__->belongs_to(
  "user",
  "FlashCards::Schema::Result::User",
  { "foreign.userId" => "self.authorId" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);
__PACKAGE__->has_one(
  "definition",
  "FlashCards::Schema::Result::Definition",
  { "foreign.definitionId" => "self.definitionId" },
  { cascade_copy => 0, cascade_delete => 1 },
);

1;
