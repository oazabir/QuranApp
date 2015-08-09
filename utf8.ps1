gci page/page*.html | % { [string]$text = (gc $_) -join "`n"; sc -Encoding utf8 $_ $text }
gci page/*.js | % { [string]$text = (gc $_) -join "`n"; sc -Encoding utf8 $_ $text }

