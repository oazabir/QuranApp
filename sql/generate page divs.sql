
SELECT '<div class="swiper-slide"><div class="page" id="page' + RIGHT('000'+ CONVERT(VARCHAR,number),3)  + '" pageno="' + CONVERT(VARCHAR,number) + '"></div></div>'
FROM master..spt_values
WHERE Type = 'P' and
Number >=1 and Number <= 604
ORDER BY Number
