insert into Card
       (userId, definitionId, question, startDate, nextDate)
select ld.userId, ld.definitionId, 'english', datetime('now'), datetime('now')
  from SelectedDefinition ld 
except
select ld.userId, ld.definitionId, c.question, datetime('now'), datetime('now')
  from SelectedDefinition ld,
       Card c
 where ld.definitionId = c.definitionId
   and ld.userId       = c.userId
   and c.question      = 'english'
go

insert into Card
       (userId, definitionId, question, startDate, nextDate)
select ld.userId, ld.definitionId, 'simplified', datetime('now'), datetime('now')
  from SelectedDefinition ld 
except
select ld.userId, ld.definitionId, c.question, datetime('now'), datetime('now')
  from SelectedDefinition ld,
       Card c
 where ld.definitionId = c.definitionId
   and ld.userId       = c.userId 
   and c.question      = 'simplified'
go

insert into Card
       (userId, definitionId, question, startDate, nextDate)
select ld.userId, ld.definitionId, 'pinyin', datetime('now'), datetime('now')
  from SelectedDefinition ld 
except
select ld.userId, ld.definitionId, c.question, datetime('now'), datetime('now')
  from SelectedDefinition ld,
       Card c
 where ld.definitionId = c.definitionId
   and ld.userId       = c.userId 
   and c.question      = 'pinyin'
go



