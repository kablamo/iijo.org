alter table setofcards add column createDate date not null;

create view PopularSets as select count(*) as users, setid from userset group by setid order by users desc;
