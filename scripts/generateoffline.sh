version=`date +%y%m%d%H%M`
pattern=00?.*
versionSuffix="?v=$version"

function header() {
	echo "CACHE MANIFEST"	
	echo "# version $version"
	echo "CACHE:"
}

function network() {
	echo "# Resources that require the user to be online."
	echo "NETWORK:"
	echo "*"	
	
}

function pagefooter() {
	echo "# Resources that require the user to be online."
	echo "NETWORK:"
	echo "*"
	fallback
}

function common() {
	find index.html -print
	find favicon.ico -print
	find images/* -type f -print
	find css/* -type f -print	
	find js/* -type f -print 
	find page/s*.js -type f 
	find data/fonts/QCF_BSML.woff -print	
}

function fallback() {
	echo " "		
	echo "FALLBACK:"
	find data/fonts/QCF_P$pattern -type f -exec echo {} /{} \;
}

function pageData() {
	find page/page$pattern -type f -exec echo /{}$versionSuffix \;
	find data/fonts/QCF_P$pattern -type f -exec echo /{} \;
	find translations/bangla/$pattern -type f -exec echo /{}$versionSuffix \;
	find translations/english/$pattern -type f -exec echo /{}$versionSuffix \;
}

function setVersion() {
	local versionMatch="\(?v=[0-9]*\)\{0,1\}"
	sed -i.tmp "s/index.js$versionMatch/index.js$versionSuffix/" $filename
	sed -i.tmp "s/common.css$versionMatch/common.css$versionSuffix/" $filename
	sed -i.tmp "s/index.appcache$versionMatch/index.appcache$versionSuffix/" $filename
	rm $filename.tmp
}

cd ~/QuranApp
# set the version number of js/css files in index.html
sed -i.tmp "s/var version = [0-9]*;/var version = $version;/" js/index.js
rm js/index.js.tmp

filename=index.html
setVersion

# generate appcache
filename=index.appcache

header > $filename
common >> $filename

# generate first couple of pages
pattern=00?.*
pageData >> $filename
# generate last couple of pages
pattern=60?.*
pageData >> $filename

network >> $filename

# generate first couple of pages
pattern=00?.*
fallback >> $filename
# generate last couple of pages
pattern=60?.*
fallback >> $filename


# put js css with version name
setVersion

# precache files for 10 pages at a time
if [ ! -z "$1" ]
then
	for (( i=10; i<=600; i+=10 ))
	do
		start="$(printf "%03d" $i)"
		end=$(( i + 9 ))
		end="$(printf "%03d" $end)"
		filename=page/$start.appcache
		pattern=${start:0:2}?.*
		echo "Cache $start and end $end in $filename using $pattern" 	
		header > $filename
		pageData >> $filename
		pagefooter /page/cache$start.html >> $filename
		setVersion
		cachehtml=page/cache$start.html
		echo "<!DOCTYPE html><html manifest=\"$start.appcache$versionSuffix\"></html>" > $cachehtml
	done
fi

# update index.html with latest appcache link
