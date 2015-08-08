DECLARE @json NVARCHAR(max)  
set @json = N''
--set @json = '<script type="text/javascript">' + CHAR(13)
set @json = @json + 'window.suraayahmap = "' 

SELECT @json = COALESCE(@json +',', '') + json FROM 
(
select convert(varchar(3),sura) + ':' + convert(varchar(3), ayah) + '=' + convert(varchar(3), page) as json from surah_page
) A

set @json = @json + '";'

print @json

declare @path varchar(100)
declare @filename varchar(100)
-- html
set @path = 'E:\Google Drive2\Islam\QuranApp\page'
set @filename = 'sura_ayah_map.js'
exec [dbo].[spWriteStringToFile]  @json, @path, @filename