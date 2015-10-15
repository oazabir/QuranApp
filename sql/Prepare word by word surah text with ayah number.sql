-- Prepare madani text after this

use quran
go

--select page, line, sura, ayah, text from madani_page
--order by page, line, sura, ayah

declare @words table (ItemIndex int, Item varchar(100))

declare c cursor for
select sura, ayah, page, text from surah_page
order by sura, ayah

declare @page int
declare @line int
declare @sura int
declare @ayah int
declare @text varchar(4000)

truncate table surah_text

open c
fetch next from c into @sura, @ayah, @page, @text

declare @wordIndex int, @word nvarchar(200), @type int
declare @revisedWordIndex int

WHILE @@FETCH_STATUS = 0
BEGIN
	
	delete from @words 
	insert into @words 
		select ItemIndex+1, Item+';' 
		from dbo.fnSplitString(@text, ';')
	
	set @revisedWordIndex = 1
	
	declare x cursor for
		select ItemIndex, Item from @words order by ItemIndex
	open x
	fetch next from x into @wordIndex, @word

	while @@FETCH_STATUS = 0
	begin
		set @type = 0

		-- ayah number
		if right(@text, len(@word)) = @word  set @type=1;
		
		-- handle stop marks		
		if exists (select * from StopMarks where Chapter = @sura and verse = @ayah and word = @wordIndex) 
		begin
			set @revisedWordIndex = @revisedWordIndex-1
			set @type = 2
		end

		INSERT INTO [dbo].[surah_text]
			   ([sura]
			   ,[ayah]
			   ,[page]
			   ,[word]
			   ,[type]
			   ,[text])     
		select @sura, @ayah, @page, @revisedWordIndex, @type, @word

		fetch next from x into @wordIndex, @word
		set @revisedWordIndex = @revisedWordIndex + 1
	end
	close x
	deallocate x

	print @page
	
	
	--fetch next from c into @page, @line, @sura, @ayah, @text
	fetch next from c into @sura, @ayah, @page, @text

END
CLOSE c
DEALLOCATE c


select count(1) from surah_text
select top 1000 * from surah_text


 
--select sura, ayah, page, text from surah_page where page = 48



--select * from dbo.fnSplitString('&#64337;&#64338;&#64339;&#64340;&#64341;&#64342;&#64343;&#64344;&#64345;&#64346;&#64347;&#64348;&#64349;&#64350;&#64351;&#64352;&#64353;&#64354;&#64355;&#64356;&#64357;&#64358;&#64359;&#64360;&#64361;&#64362;&#64363;&#64364;&#64365;&#64366;&#64367;&#64368;&#64369;&#64370;&#64371;&#64372;&#64373;&#64374;&#64375;&#64376;&#64377;&#64378;&#64379;&#64380;&#64381;&#64382;&#64383;&#64384;&#64385;&#64386;&#64387;&#64388;&#64389;&#64390;&#64391;&#64392;&#64393;&#64394;&#64395;&#64396;&#64397;&#64398;&#64399;&#64400;&#64401;&#64402;&#64403;&#64404;&#64405;&#64406;&#64407;&#64408;&#64409;&#64410;&#64411;&#64412;&#64413;&#64414;&#64415;&#64416;&#64417;&#64418;&#64419;&#64420;&#64421;&#64422;&#64423;&#64424;&#64425;&#64426;&#64427;&#64428;&#64429;&#64430;&#64431;&#64432;&#64433;&#64467;&#64468;&#64469;&#64470;&#64471;&#64472;&#64473;&#64474;&#64475;&#64476;&#64477;&#64478;&#64479;&#64480;&#64481;&#64482;&#64483;&#64484;&#64485;&#64486;&#64487;&#64488;&#64489;&#64490;&#64491;&#64492;&#64493;&#64494;&#64495;&#64496;&#64497;&#64498;&#64499;&#64500;&#64501;&#64502;&#64503;&#64504;&#64505;&#64506;&#64507;&#64508;&#64509;&#64510;&#64511;&#64512;&#64513;&#64514;', ';')