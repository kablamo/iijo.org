alter table User rename to userx;
create table if not exists User (
   userId     integer not null primary key autoincrement,
   facebookId varchar default null,
   openId     varchar default null,
   username   varchar not null,
   password   varchar default null,
   email      varchar default null,
   gravatar   varchar default null,
   guest      varchar default 'y',
   unique (username),
   unique (facebookId),
   unique (openId),
   unique (email)
);
delete from userx where username = 'guest user';
insert into User 
      (userId, facebookId, openId, username, password, email, gravatar) 
select userId, facebookId, openId, username, password, email, gravatar from userx;
-- drop table userx;
