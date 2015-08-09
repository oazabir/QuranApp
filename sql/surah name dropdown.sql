use Quran

DECLARE @html NVARCHAR(max)  
set @html = N''
--set @html = '<script type="text/javascript">' + CHAR(13)
set @html = @html + '<select>' 

SELECT @html = COALESCE(@html + char(13), '') + html FROM 
(
select N'<option value="' + convert(nvarchar(3),sura) + '">' + convert(nvarchar(3),sura) + ' ' + English + ' ' + Bangla + ' ' + Arabic + '</option>' as html FROM
(
  select sura, page, text COLLATE Arabic_100_CI_AI as text, s.Name as Arabic, b.Name as Bangla, e.Name as English  from madani_page 
  join SurahNames b on b.SurahNo = sura and b.LanguageID = 2
  join SurahNames e on e.SurahNo = sura and e.LanguageID = 1
  join Surahs s on s.ID = sura 
  where ayah = 0 and len(text) < 20
  
) A
) B

set @html = @html + CHAR(13) + '</select>' + CHAR(13) 


declare @path varchar(100)
declare @filename varchar(100)
set @path = 'E:\Google Drive2\Islam\QuranApp\page'
set @filename = 'surahs.html'
exec [dbo].[spWriteStringToFile]  @html, @path, @filename

print @html