use Quran
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
					+ 'class="' + (case B.type when 0 then 'word' when 1 then 'ayah_number' else 'surah_name' end) 
					+ '" sura="' + convert(nvarchar(3), B.sura) 
					+ '" ayah="' + convert(nvarchar(3), B.ayah) 
					+ '" word="' + convert(nvarchar(3), B.word) 
					+ '">' 
					+ text + '</span>'
				FROM
					(		 
						select line, sura, ayah, word, type, text from madani_text m where m.page = @page_no and m.line = A.line
					) B
				order by sura, ayah, word
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

/*

-- Generate JSON for the page

DECLARE @json NVARCHAR(max)  
set @json = N''
--set @json = '<script type="text/javascript">' + CHAR(13)
set @json = @json + 'window.wordbyword = $.extend(window.wordbyword || {}, {' 

SELECT @json = COALESCE(@json + char(13), '') + json FROM 
(
select top 100 percent N'"' + convert(nvarchar(50),chapter)+':'+convert(nvarchar(50),verse)+':'+convert(nvarchar(50),word) 
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
	+ '"},' as json FROM


(
	select * from 
	(
		select 
		chapter 
		,verse 
		,case  
			when chapter > 1 and verse = 1 then word-4 
			else word end 
		as Word
		,Root
		,lemma
		,isnull((select count(1) from WordInformation w1 where w1.root = w.root and w1.lemma = w.lemma),0) as lemmacount
		,isnull((select arabic from ArabicWords where ID = (select top 1 ArabicWordID from Meanings where SurahNo = chapter and VerseNo = verse and WordNo = word)), Transliteration) as Transliteration
		
		,ltrim(rtrim(text)) as text
		
		,isnull((select top 1 replace(rtrim(ltrim(EnglishMeaning)),'"', '') from Meanings where SurahNo = chapter and VerseNo = verse and WordNo = word),Meaning) as meaning
		--,replace(rtrim(ltrim(meaning)),'"', '') as meaning
		
		,isnull((select translation_id from Indonesia where sura = w.Chapter and vers = w.Verse and pos = w.Word), '') as Indonesia

		,replace(
		replace(
		ltrim(rtrim(ISNULL((
			select top 1 bangla from [BanglaWordbyWord] b where b.Word = w.Text 
		), '')))
		,'"', '')
		,'''', '')
		as Bangla
		
		,ISNULL((select count(1) from [WordInformation] w1 where w1.root = w.root and w1.text = w.text ), 0) as Frequency
	
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
		as RootMeaning

		from wordinformation w 
		
		where word > 0
		and exists (select * FROM surah_page 
		where page = @page_no and Chapter = sura and Verse = ayah)
	) A		
) B
--order by B.Chapter, B.Verse, B.Word
group by chapter, verse, word, text, Root, Lemma, LemmaCount, Transliteration, LemmaBangla, meaning, Bangla, Indonesia, Frequency, rootmeaning
) C


set @json = @json + CHAR(13) + '});' + CHAR(13) -- + '</script>' + CHAR(13)


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
	+ '"},' as json FROM
	(
		select e.surahno, e.ayahno, e.content as English, b.content as Bangla
		from Ayahs e inner join Ayahs b on b.SurahNo = e.SurahNo and b.AyahNo = e.AyahNo
		where 
		e.TranslatorID = 45
		AND b.TranslatorID = 5
		and exists (select * FROM surah_page 
		where page = @page_no and e.surahno = sura and e.ayahno = ayah)
	) B
) C

set @translations = @translations + CHAR(13) + '});' + CHAR(13) 

--print @json

--print @translations

*/

declare @path varchar(100)
declare @filename varchar(100)

-- html
set @path = 'E:\GitHub\QuranApp\page'
set @filename = 'page' + @pagestr + '.html'
exec [dbo].[spWriteStringToFile]  @html, @path, @filename


-- json
/*
declare @content nvarchar(max)
set @content = @json + @translations
set @filename = 'page' + @pagestr + '.js'
exec [dbo].[spWriteStringToFile]  @content, @path, @filename
*/


   SET @page_no = @page_no + 1;
END;
