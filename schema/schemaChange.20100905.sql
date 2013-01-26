
alter table user rename to userx;
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
insert into user (userId, username, password, email, guest)
select userId, username, password, email, guest
  from userx;
update user set slug = username;


alter table setofcards rename to setofcardsx;
create table if not exists SetOfCards (
   setId       integer     not null primary key autoincrement,
   name        varchar default null,
   description varchar default null,
   authorId    integer     not null,
   slug        varchar default null,
   foreign key (authorId) references User (userId)
);
insert into setofcards (setId, name, description, authorId)
select setId, name, description, authorId
  from setofcardsx;
update setofcards set slug = name;
update setofcards set slug = lower(slug);
update setofcards set slug = replace(slug, ' ', '-');
update setofcards set slug = replace(slug, '/', '-');


alter table definition rename to definitionx;
create table if not exists Definition (
   definitionId integer not null primary key autoincrement,
   english      varchar not null,
   simplified   varchar,
   complex      varchar default null,
   pinyin       varchar not null,
   slug         varchar default null
);
insert into definition (definitionId, english, simplified, complex, pinyin)
select definitionId, english, simplified, complex, pinyin
  from definitionx;


