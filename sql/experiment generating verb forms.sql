use quran
go 
declare @verbforms nvarchar(max)


set @verbforms = N''

SELECT @verbforms = COALESCE(@verbforms + char(13), '') + html FROM 
(
select 
	N'window.verbforms["'+root+'"]=(window.verbforms["'+root+'"]||"")+"<tr><td>'+ISNULL(Form,'')+'</th><th>'+ISNULL(Perfect,'')+'</th><th>'+ISNULL(Imperfect,'')+'</th><th>'+ISNULL(ActiveParticiple,'')+'</th><th>'+ISNULL(PassiveParticiple,'')+'</th><th>'+ISNULL(VerbalNoun,'')+'</th></tr>";' 
	as html
	FROM
(
SELECT [Root]
      ,[Form]
      ,[Perfect]
      ,[Imperfect]
      ,[ActiveParticiple]
      ,[PassiveParticiple]
      ,[VerbalNoun]
  FROM [Quran].[dbo].[VerbFormsByRoot]
  where root in (select distinct root from wordpartinformation 		
		where word > 0
		and type = 'STEM'
		and Position = 'V'
		and exists (select * FROM surah_page 
		where page = 1 and Chapter = sura and Verse = ayah))
) A
) B

set @verbforms = @verbforms + N'</table>'

print @verbforms