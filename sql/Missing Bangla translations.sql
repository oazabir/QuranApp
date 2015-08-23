
;with MissingWords
AS( 
	select distinct text from WordInformation where text not in (select distinct word from BanglaWordByWord)
)
, AyahContainingWord 
AS (
	select top 1 Chapter, Verse, text from WordInformation 
)
, Ayah 
AS (
select surahno, ayahno, content from Ayahs where translatorid = 7
)
, EnglishAyah 
AS (
select surahno, ayahno, content from Ayahs where translatorid = 45
)
, BanglaAyah
AS (
select surahno, ayahno, content from Ayahs where translatorid = 5
)
select text, 
Chapter, Verse, 
(select content from Ayah where surahno = Chapter and AyahNo = verse) as arabic,
(select content from EnglishAyah where surahno = Chapter and AyahNo = verse) as English,
(select content from BanglaAyah where surahno = Chapter and AyahNo = verse) as Bangla 

FROM 
(
select text, (select top 1 Chapter from WordInformation w 
where w.text = m.text) as Chapter, (select top 1 Verse from WordInformation w 
where w.text = m.text) as Verse  from MissingWords m
) A
order by text