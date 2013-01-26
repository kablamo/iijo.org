
drop table User;
drop table SetOfCards;
drop table Definition;
drop table Card;
drop table UserSet;
drop table SetDefinition;

create table if not exists User (
   userId     integer not null primary key autoincrement,
   facebookId varchar default null,
   openId     varchar default null,
   username   varchar not null,
   password   varchar default null,
   email      varchar default null,
   gravatar   varchar default null,
   guest      varchar default 'y',
   slug       varchar default null,
   unique (username),
   unique (facebookId),
   unique (openId),
   unique (email)
);

create table if not exists SetOfCards (
   setId       integer     not null primary key autoincrement,
   name        varchar default null,
   description varchar default null,
   authorId    integer     not null,
   slug        varchar default null,
   foreign key (authorId) references User (userId)
);

create table if not exists Definition (
   definitionId integer not null primary key autoincrement,
   english      varchar not null,
   simplified   varchar,
   complex      varchar default null,
   pinyin       varchar not null,
   slug         varchar default null
);

create table if not exists Card (
   cardId        integer not null primary key autoincrement,
   userId        integer not null,
   definitionId  integer not null,
   question      varchar not null,
   startDate     date    not null,
   lastDate      date             default null,
   nextDate      date             default null,
   lastAnswer    varchar          default null,
   delayExponent integer not null default 0,
   unique (userId, definitionId, question),
   foreign key (userId)       references User       (userId),
   foreign key (definitionId) references Definition (definitionId)
);

create table if not exists UserSet (
   userId       integer not null default null,
   setId        integer not null default null,
   primary key (userId, setId),
   foreign key (userId) references User       (userId),
   foreign key (setId)  references SetOfCards (setId)
);

create table if not exists SetDefinition (
   setId           integer not null default null,
   definitionId    integer not null default null,
   authorId        integer not null default null,
   primary key (setId, definitionId),
   foreign key (setId)        references SetOfCards (setId),
   foreign key (definitionId) references Definition (definitionId),
   foreign key (authorId)     references User       (userId)
);

create table if not exists SelectedDefinition (
   setId                integer not null,
   definitionId         integer not null,
   userId               integer not null,
   primary key (setId, definitionId, userId),
   foreign key (userId)       references User       (userId),
   foreign key (setId)        references SetOfCards (setId),
   foreign key (definitionId) references Definition (definitionId)
);

