-- this data set is useful for humans who wish to browse the site in a dev
-- environment and examine how their changes work.
-- 
-- probably test cases will build on whats in here.
-- 
-- 

insert into user (user_id, username, password, gravatar, email)
values (1, 'eric', 'eric', 'eric', 'eric');
insert into playlist (user_id, playlist_name)
values (1, 'my playlist');
