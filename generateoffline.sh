version=`date +%y%m%d%H%M`
pattern=00?.*
jsVersion=`grep version js/index.js | grep -oE "\d+"`
versionSuffix="?v=$jsVersion"

function header() {
	echo "CACHE MANIFEST"	
	echo "# version $version"
	echo "CACHE:"
}

function footer() {
	echo "# Resources that require the user to be online."
	echo "NETWORK:"
	echo "*"
	echo " "		
	echo "FALLBACK:"
	echo "index.html"
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

function setVersion() {
	sed -i.tmp 's/index.js?v=[0-9]*/index.js$versionSuffix/' $filename
	sed -i.tmp 's/common.css?v=[0-9]*/common.css$versionSuffix/' $filename
}

function pageData() {
	find page/page$pattern -type f -exec echo {}$versionSuffix \;
	find translations/bangla/$pattern -type f -exec echo {}$versionSuffix \;
	find translations/english/$pattern -type f -exec echo {}$versionSuffix \;
	find data/fonts/QCF_P$pattern -type f -print
}


# set the version number of js/css files in index.html
filename=index.html
setVersion


# generate appcache
header > $filename
common >> $filename

# generate first 10 pages
pattern=00?.*
pageData >> $filename

pattern=60?.*
pageData >> $filename

footer >> $filename
setVersion


