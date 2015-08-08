gci page*.html | % { [string]$text = (gc $_) -join "`n"; sc -Encoding utf8 $_ $text }
gci *.js | % { [string]$text = (gc $_) -join "`n"; sc -Encoding utf8 $_ $text }

