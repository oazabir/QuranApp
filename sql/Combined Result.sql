--drop table LemmaMeaningUsageAyah3
go


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT ISNULL(dbo.SplitRoot(l.[Root]),'') as Root
      ,l.[Lemma]
      ,l.[Occurences]
      --,[Meaning]

	  ,ISNULL((select top 1 b.Bangla from 
				Bangla b 
				WHERE b.Word = l.Lemma 
				AND b.Root = l.Root),'') as Bangla
      --,[Verse2]
	  ,(select top 1 
				Ayah + char(13) + 
				Translation2 + ' [' + dbo.GetSurahName(Chapter) + ' ' + Convert(nvarchar(3),Chapter) + ':' + Convert(nvarchar(3),Verse) + ']' 
				from [dbo].[GetVersesFromLemma2](l.Root, l.Lemma)
				order by Length) as Translation
      --,[Usage2]
	  ,ISNULL([dbo].[GetLemmaUsage](l.Root, l.Lemma,10),'') as Usage3
	  ,ISNULL((SELECT Meaning from ArabicRootMeaning a WHERE a.Root = l.Root),'') as RootMeaning
--INTO LemmaMeaningUsageAyah3
FROM (

SELECT TOP 100 percent
		[Root],
      [Lemma],     
	   Occurences	  
  FROM [dbo].[WordsForQuizlet]  
  order by Occurences DESC

) L
ORDER BY l.Occurences DESC



--select count(1) from LemmaMeaningUsageAyah3 


--select * from wordpartinformation where lemma = N'قِيَٰمَة'