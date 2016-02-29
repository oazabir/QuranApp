# version for js, css 
resourceVersion=`date +%y%m%d%H%M`
resourceVersionSuffix="?v=$resourceVersion"
# version for data files
dataVersion=`cat dataversion.txt || date +%y%m%d%H%M`
# If data files are changed as indicated via command line arg, then generate new data version
[ ! -z "$1" ] && dataVersion=`date +%y%m%d%H%M`
echo $dataVersion > dataversion.txt
dataVersionSuffix="?v=$dataVersion"

pattern=00?.*

function header() {
	echo "CACHE MANIFEST"	
	echo "# version $resourceVersion"
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
	find page/page$pattern -type f -exec echo /{}$dataVersionSuffix \;
	find data/fonts/QCF_P$pattern -type f -exec echo /{} \;
	find translations/bangla/$pattern -type f -exec echo /{}$dataVersionSuffix \;
	find translations/english/$pattern -type f -exec echo /{}$dataVersionSuffix \;
}

function setVersion() {
	local versionMatch="\(?v=[0-9]*\)\{0,1\}"
	sed -i.tmp "s/index.js$versionMatch/index.js$resourceVersionSuffix/" $filename
	sed -i.tmp "s/common.css$versionMatch/common.css$resourceVersionSuffix/" $filename
    sed -i.tmp "s/nightmode.css$versionMatch/common.css$resourceVersionSuffix/" $filename
	sed -i.tmp "s/index.appcache$versionMatch/index.appcache$resourceVersionSuffix/" $filename
	sed -i.tmp "s/surahs.js$versionMatch/surahs.js$resourceVersionSuffix/" $filename
	sed -i.tmp "s/sura_ayah_map.js$versionMatch/sura_ayah_map.js$resourceVersionSuffix/" $filename
	
	rm $filename.tmp
}

cd ~/QuranApp
# set the version number of js/css files in index.html
sed -i.tmp "s/var version = [0-9]*;/var version = $dataVersion;/" js/index.js
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
		echo "<!DOCTYPE html><html manifest=\"$start.appcache$resourceVersionSuffix\"></html>" > $cachehtml
	done
fi

# update index.html with latest appcache link
