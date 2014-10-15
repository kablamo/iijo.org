-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Apr  9 22:19:02 2014
-- 

BEGIN TRANSACTION;

--
-- Table: User
--
DROP TABLE User;

CREATE TABLE User (
  userId INTEGER PRIMARY KEY NOT NULL,
  facebookId varchar DEFAULT null,
  openId varchar DEFAULT null,
  username varchar NOT NULL,
  password varchar DEFAULT null,
  email varchar DEFAULT null,
  gravatar varchar DEFAULT null,
  guest varchar DEFAULT 'y',
  slug varchar DEFAULT null
);

CREATE UNIQUE INDEX email_unique ON User (email);

CREATE UNIQUE INDEX facebookid_unique ON User (facebookId);

CREATE UNIQUE INDEX openid_unique ON User (openId);

CREATE UNIQUE INDEX username_unique ON User (username);

COMMIT;
