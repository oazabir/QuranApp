use QuranApp
go


DECLARE @page_no numeric = 1;

WHILE @page_no <= 604
BEGIN

declare @pagestr nvarchar(3)
set @pagestr =  RIGHT('000'+ CONVERT(VARCHAR,@page_no),3) 

-- generate html output

DECLARE @html NVARCHAR(max)  
set @html = N' '

-- get surah name
declare @surahname nvarchar(max)
select @surahname = text from madani_page
where sura = (select min(sura) from madani_page where page = @page_no)
and ayah = 0 and len(text) < 20

set @html = @html + N'<div class="surah_title"><a href="#surahpanel" id="surahNameButton">' + @surahname + N'</a></div>' + CHAR(13) + N'<div class="page_content">'

-- prepare ayah lines

SELECT @html = COALESCE(@html + char(13), '') + text FROM 
(
select line,
	case  
		when ayah = 0 then 
			case when len(text) > 16 then '<div class="basmalah">' + text + '</div>'
			else '<div class="surah_name">' + text + '</div>'
			
			end
		else '<div class="page' + @pagestr + ' line">' 
			+ (


				select STUFF((
				select '<span ' 
					+ 'class="' + (case B.type when 0 then 'word' when 1 then 'ayah_number' when 2 then 'stop_mark' else 'surah_name' end) 
					+ '" sura="' + convert(nvarchar(3), B.sura) 
					+ '" ayah="' + convert(nvarchar(3), B.ayah) 
					+ '" word="' + convert(nvarchar(3), B.word) 
					+ '" type="' + convert(nvarchar(3), B.type) 
					+ '">' 
					+ text + '</span>'
				FROM
					(		 
						select line, pos, sura, ayah, word, type, text from madani_text m where m.page = @page_no and m.line = A.line
					) B
				order by line, pos --sura, ayah, word, type
				FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 0, '')

			)
			+ '</div>'
	end as text
FROM
	(
		select line, sura, ayah, text from madani_page p where page=@page_no
	) A
) B
order by B.line

-- generate page number

set @html = @html + N'<div class="page_no"><a href="#pagejumppanel" id="pagejumpbutton" data-rel="popup">' + dbo.udf_GetArabicNumbers(@page_no) + N'</a></div>'

set @html = @html + CHAR(13) + '</div>' --+ CHAR(13) + '</div>' + CHAR(13)

print @html



declare @bangla_translation nvarchar(max)
set @bangla_translation = dbo.GenerateTranslation( 5, 2, @page_no) -- bangla


declare @english_translation nvarchar(max)
set @english_translation = dbo.GenerateTranslation( 45, 1, @page_no) -- bangla

print @bangla_translation
print @english_translation

-- Generate JSON for the page

DECLARE @json NVARCHAR(max)  
set @json = N''
--set @json = '<script type="text/javascript">' + CHAR(13)
set @json = @json + 'window.wordbyword = $.extend(window.wordbyword || {}, {' 

SELECT @json = COALESCE(@json + char(13), '') + json FROM 
(
	select chapter, verse, word, N'"' + convert(nvarchar(50),chapter)+':'+convert(nvarchar(50),verse)+':'+convert(nvarchar(50),word) 
		+ '" : {s: ' + convert(nvarchar(50),chapter) 
		+ ', a: ' + convert(nvarchar(50),verse) 
		+ ', w: ' + convert(nvarchar(50),word) 
		+ ', r: "' + Root 
		+ '", t: "' + text 
		+ '", l: "' + lemma 
		+ '", lc: ' + convert(nvarchar(5),lemmacount)
		+ ', tl: "' + replace(Transliteration, '"', '')
		+ '", lb: "' + replace(ltrim(rtrim(LemmaBangla)), '"', '')
		+ '",e: "' + replace(ltrim(rtrim(meaning)), '"', '')
		+ '", b: "' + replace(rtrim(ltrim(bangla)), '"', '')
		+ '", i: "' + replace(Indonesia, '"', '')
		+ '", f: ' + convert(nvarchar(6),frequency) 
		+ ', rm: "' + replace(replace(replace(RootMeaning, '"', ''), char(13), ' '),char(10), '')
		+ '", ag: "' + replace(replace(replace(ArabicGrammar, '"', ''), char(13), ' '),char(10), '')
		+ '", eg: "' + replace(replace(replace(EnglishGrammar, '"', ''), char(13), ' '),char(10), '')

		+ '", tag: "' + replace(ltrim(rtrim(ISNULL(Tag,''))), '"', '')
		+ '", pos: "' + replace(ltrim(rtrim(ISNULL([Position],''))), '"', '')
		+ '", att: "' + replace(ltrim(rtrim(ISNULL([Attribute],''))), '"', '')
		+ '", qual: "' + replace(ltrim(rtrim(ISNULL([Qualifier],''))), '"', '')
		+ '", deg: "' + replace(ltrim(rtrim(ISNULL([PersonDegree],''))), '"', '')
		+ '", gen: "' + replace(ltrim(rtrim(ISNULL([PersonGender],''))), '"', '')
		+ '", num: "' + replace(ltrim(rtrim(ISNULL([PersonNumber],''))), '"', '')
		+ '", mood: "' + replace(ltrim(rtrim(ISNULL([Mood],''))), '"', '')

		+ '", lu: "' + replace(ltrim(rtrim(ISNULL(LemmaUsage,''))), '"', '')
		+ '"},' COLLATE Latin1_General_CI_AS  as json FROM


	(
		select 

		w.chapter 
		,w.verse 
		,case  
			when w.chapter > 1 and w.verse = 1 then w.word-4 
			else w.word end 
		as Word
		,w.Root
		,w.lemma
		,isnull((select Totals from RootLemmaCount w1 where w1.root = w.root and w1.lemma = w.lemma),0) as lemmacount
		,isnull((select arabic from ArabicWords where ID = m.ArabicWordID), w.Transliteration) as Transliteration
		
		,ltrim(rtrim(w.text)) as text
		
		,isnull(m.EnglishMeaning, w.Meaning) as meaning
		--,replace(rtrim(ltrim(meaning)),'"', '') as meaning
		
		,isnull((select translation_id from Indonesia where sura = w.Chapter and vers = w.Verse and pos = w.Word), '') as Indonesia

		,replace(
		replace(
		ltrim(rtrim(ISNULL((
			--select top 1 bangla from [BanglaWordbyWord] b where b.Word = w.Text 
			select [translate_bn] from [dbo].[BanglaWordbyWordOS]
			where surah_id = w.Chapter and verse_id = w.Verse 
			and words_id = (case  
			when w.chapter > 1 and w.verse = 1 then w.word-4 
			else w.word end )
		), '')))
		,'"', '')
		,'''', '')
		as Bangla
		
		,ISNULL(rtc.Totals, 0) as Frequency
	
		,replace(
			ISNULL((select top 1 b.Bangla from 
				Bangla b 
				WHERE b.Word = w.Lemma 
				AND b.Root = w.Root),'') 
		,'''', '')
		as LemmaBangla	

		,replace(
			ISNULL((SELECT Meaning from ArabicRootMeaning a WHERE a.Root = w.Root),'')
		,'''', '')
		as RootMeaning,

		ISNULL(g.ArabicGrammar, '') as ArabicGrammar,
		ISNULL(g.EnglishGrammar, '') as EnglishGrammar
		
		,p.Tag
		,p.[Position]
		,p.[Attribute]
		,p.[Qualifier]
		,p.[PersonDegree]
		,p.[PersonGender]
		,p.[PersonNumber]
		,p.[Mood]

		,dbo.GetLemmaUsage(w.Root, NULL, 5) as LemmaUsage

		from wordinformation w 
		left join WordGrammar g on g.Chapter = w.Chapter and g.Verse = w.Verse and g.Word = w.Word
		left join WordPartInformation p on 
			p.Chapter = w.Chapter and 
			p.Verse = w.Verse and 
			p.Word = w.Word and
			p.Type = 'STEM'
		left join Meanings m ON 
			m.SurahNo = w.chapter and 
			m.VerseNo = w.verse and 
			m.WordNo = (case  
			when w.chapter > 1 and w.verse = 1 then w.word-4 
			else w.word end )
		left join RootTextCount rtc on rtc.root = w.root and rtc.text = w.text
		where w.word > 0
		and exists (select * FROM surah_page 
		where page = @page_no and sura = w.Chapter and ayah = w.Verse)
	) INLINE_QUERY		
	--order by Chapter, Verse, Word
--) B
	--order by Chapter, Verse
--group by chapter, verse, word, text, Root, Lemma, LemmaCount, Transliteration, LemmaBangla, meaning, Bangla, Indonesia, Frequency, rootmeaning
--order by Chapter, Verse, Word
) JSON
group by Chapter, Verse, Word, json



set @json = @json + CHAR(13) + '});' + CHAR(13) -- + '</script>' + CHAR(13)
print @json


declare @translations nvarchar(max)
set @translations = N'window.translation = $.extend(window.translation || {}, {'
-- generate translations
SELECT @translations = COALESCE(@translations + char(13), '') + json FROM 
(
select N'"' + convert(nvarchar(50),surahno)+':'+convert(nvarchar(50),ayahno)
	+ '" : {s: ' + convert(nvarchar(50),surahno) 
	+ ', a: ' + convert(nvarchar(50),ayahno) 	
	+ ', e: "' + replace(English, '"', '')
	+ '", b: "' + replace(Bangla, '"', '')
	+ '", t: "' + replace(Arabic, '"', '')
	+ '"},' as json FROM
	(
		select e.surahno, e.ayahno, a.Content as Arabic, e.content as English, b.content as Bangla
		from Ayahs e inner join Ayahs b on b.SurahNo = e.SurahNo and b.AyahNo = e.AyahNo
		inner join Ayahs a on a.SurahNo = e.SurahNo and a.AyahNo = e.AyahNo
		where 
		a.TranslatorID = 7
		and e.TranslatorID = 45
		AND b.TranslatorID = 5
		and exists (select * FROM surah_page 
		where page = @page_no and e.surahno = sura and e.ayahno = ayah)
	) B
) C

set @translations = @translations + CHAR(13) + '});' + CHAR(13) 

--print @json

print @translations
/*
declare @verbforms nvarchar(max)
set @verbforms = N'window.verbforms = window.verbforms || {};' + char(13)

SELECT @verbforms = COALESCE(@verbforms + char(13), '') + json FROM 
(
select 
	N'window.verbforms["'+root+'"] = (window.verbforms["'+root+'"]||{}); window.verbforms["'+root+'"]["'+Form+'"] ="<tr><td>'+ISNULL(Form,'')+'</td><td>'+ISNULL(Perfect,'')+'</td><td>'+ISNULL(Imperfect,'')+'</td><td>'+ISNULL(ActiveParticiple,'')+'</td><td>'+ISNULL(PassiveParticiple,'')+'</td><td>'+ISNULL(VerbalNoun,'')+'</td></tr>";' 
	as json
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
		where page = @page_no and Chapter = sura and Verse = ayah))
		
		
) A
) B

print @verbforms
*/

declare @path varchar(100)
declare @filename varchar(100)

-- html
set @path = 'c:\QuranApp\page'
set @filename = 'page' + @pagestr + '.html'
exec [dbo].[spWriteStringToFile]  @html, @path, @filename
-- json

declare @content nvarchar(max)
set @content = @json + @translations -- + @verbforms
set @filename = 'page' + @pagestr + '.js'
exec [dbo].[spWriteStringToFile]  @content, @path, @filename


-- translation
set @path = 'c:\QuranApp\translations\bangla'
set @filename = @pagestr + '.html'
exec [dbo].[spWriteStringToFile]  @bangla_translation, @path, @filename

set @path = 'c:\QuranApp\translations\english'
set @filename = @pagestr + '.html'
exec [dbo].[spWriteStringToFile]  @english_translation, @path, @filename


   SET @page_no = @page_no + 1;
END;
