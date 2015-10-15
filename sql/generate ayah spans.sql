declare @text nvarchar(max)
set @text = N'&#64392;&#64393;&#64394;&#64395;&#64396;&#64397;&#64398;&#64399;&#64400;&#64401;&#64402;'
select * from  [dbo].[SplitString](@text, ';')


select '<span ' 
	+ 'class="' + class 
	+ '" sura="' + convert(nvarchar(3), sura) 
	+ '" ayah="' + convert(nvarchar(3), ayah) 
	+ '" word="' + convert(nvarchar(3), itemindex) 
	+ '">' 
	+ item + ';</span>' as word
FROM
	(		 
		 select 
			1 as sura
			,2 as ayah
			,(select ItemIndex+1 from (select (
				select Item from [dbo].[SplitString](s.text, ';')) as AyahNumber from surah_page s where s.page=603) A 
						where A.AyahNumber = Item)
			,case when 
				exists (select * from (select (select top 1 Item from [dbo].[SplitString](text, ';') where len(item)>0 order by  ItemIndex desc) as AyahNumber from surah_page s where s.page=603) A 
						where A.AyahNumber = Item)
				then 'ayah_number' 
				else 'word'
			end as class
			,item 
		 FROM [dbo].[SplitString](@text, ';')
	) A
where len(item)>0





--select (select top 1 Item from [dbo].[SplitString](text, ';') where len(item)>0 order by  ItemIndex desc) as AyahNumber from surah_page where page=1



select (select top 1 Item from [dbo].[SplitString](text, ';')) as AyahNumber from surah_page where page=1