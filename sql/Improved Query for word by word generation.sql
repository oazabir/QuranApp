set statistics io on 

set statistics time on

select 

		w.chapter 
		,w.verse 
		,case  
			when w.chapter > 1 and w.verse = 1 then w.word-4 
			else w.word end 
		as Word
		,w.Root
		,w.lemma
		,isnull(rlc.Totals,0) as lemmacount
		,isnull((select arabic from ArabicWords where ID = m.ArabicWordID), w.Transliteration) as Transliteration
		
		,ltrim(rtrim(w.text)) as text
		
		,isnull(m.EnglishMeaning, w.Meaning) as meaning
		--,replace(rtrim(ltrim(meaning)),'"', '') as meaning
		
		,isnull((select translation_id from Indonesia where sura = w.Chapter and vers = w.Verse and pos = w.Word), '') as Indonesia

		,replace(
		replace(
		ltrim(rtrim(ISNULL((bww.bangla), '')))
		,'"', '')
		,'''', '')
		as Bangla
		
		,ISNULL(rtc.Totals, 0) as Frequency
	
		,replace(
			ISNULL((b.Bangla),'') 
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
			m.WordNo = w.word
		left join RootTextCount rtc on rtc.root = w.root and rtc.text = w.text
		left join RootLemmaCount rlc on rlc.root = w.root and rlc.lemma = w.lemma
		left join [BanglaWordbyWord] bww on bww.Word = w.Text 
		left join Bangla b on b.Word = w.Lemma AND b.Root = w.Root
		where w.word > 0
		and exists (select * FROM surah_page 
		where page = 130 and sura = w.Chapter and ayah = w.Verse)