with duplicates AS (
select surah_id, verse_id, words_id, row_number() OVER (partition by surah_id, verse_id, words_id ORDER BY surah_id, verse_id, words_id) as [RN] 
from BanglaWordbyWordOS 
)
DELETE duplicates where RN > 1