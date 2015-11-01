

declare c cursor for
select page, line, sura, ayah, text from madani_page
order by page, line, sura, ayah

declare @page int
declare @line int
declare @sura int
declare @ayah int
declare @text varchar(4000)

truncate table madani_text

open c
fetch next from c into @page, @line, @sura, @ayah, @text


WHILE @@FETCH_STATUS = 0
BEGIN
	
	print STR(@page) + ' ' +  str(@sura) + ' ' + str(@ayah)
	
	INSERT INTO [dbo].[madani_text]
           ([page]
		   ,[line]
		   ,[pos]
		   ,[sura]
           ,[ayah]
           ,[word]
           ,[type]
           ,[text])     
	select @page, @line, ItemIndex+1,
		@sura, 
		s.ayah, --(select ayah from surah_text where page = @page and sura = @sura and text = (Item+';')),
		s.word, --(select word from surah_text where page = @page and sura = @sura and text = (Item+';')),
		--isnull((select type from surah_text where page = @page and sura = @sura and text = (Item+';')), 2),
		isnull(s.type, 2),
		Item + ';'
	from dbo.fnSplitString(@text, ';')
	join surah_text s on s.page = @page and s.sura = @sura and s.text = Item+';'
	
	
	fetch next from c into @page, @line, @sura, @ayah, @text

END
CLOSE c
DEALLOCATE c

select * from surah_text s
where not exists (select * from madani_text m where m.page = s.page and m.sura = s.sura and m.ayah = s.ayah)

select sura, ayah, min(word) mm, max(word) mw from surah_text group by sura, ayah
except
select sura, ayah, min(word) mm, max(word) mw from madani_text group by sura, ayah


select * from madani_text


--select sura, ayah, page, text from surah_page where page = 48



--select * from dbo.fnSplitString('&#64337;&#64338;&#64339;&#64340;&#64341;&#64342;&#64343;&#64344;&#64345;&#64346;&#64347;&#64348;&#64349;&#64350;&#64351;&#64352;&#64353;&#64354;&#64355;&#64356;&#64357;&#64358;&#64359;&#64360;&#64361;&#64362;&#64363;&#64364;&#64365;&#64366;&#64367;&#64368;&#64369;&#64370;&#64371;&#64372;&#64373;&#64374;&#64375;&#64376;&#64377;&#64378;&#64379;&#64380;&#64381;&#64382;&#64383;&#64384;&#64385;&#64386;&#64387;&#64388;&#64389;&#64390;&#64391;&#64392;&#64393;&#64394;&#64395;&#64396;&#64397;&#64398;&#64399;&#64400;&#64401;&#64402;&#64403;&#64404;&#64405;&#64406;&#64407;&#64408;&#64409;&#64410;&#64411;&#64412;&#64413;&#64414;&#64415;&#64416;&#64417;&#64418;&#64419;&#64420;&#64421;&#64422;&#64423;&#64424;&#64425;&#64426;&#64427;&#64428;&#64429;&#64430;&#64431;&#64432;&#64433;&#64467;&#64468;&#64469;&#64470;&#64471;&#64472;&#64473;&#64474;&#64475;&#64476;&#64477;&#64478;&#64479;&#64480;&#64481;&#64482;&#64483;&#64484;&#64485;&#64486;&#64487;&#64488;&#64489;&#64490;&#64491;&#64492;&#64493;&#64494;&#64495;&#64496;&#64497;&#64498;&#64499;&#64500;&#64501;&#64502;&#64503;&#64504;&#64505;&#64506;&#64507;&#64508;&#64509;&#64510;&#64511;&#64512;&#64513;&#64514;', ';')