//The directory to store data
var store;
var reciter;
var sura;
var aya;
var defaultReciter = 'Husary_128kbps';

function play(s, a) {
	play(defaultReciter, s, a);
}

function play(r, s, a) {
	reciter = r;
	sura = threeDigits(s);
	aya = threeDigits(a);
	
	store = cordova.file.dataDirectory + 'mp3/';
	window.resolveLocalFileSystemURL(getLocalFile(), playLocalFile, downloadFile);
}

function threeDigits(num) {
	var temp = '000'+ num;
	return temp.substr(temp.length-3);
}

function getLocalFile() {
	return store + '/' + reciter + '/' + sura + '/' + aya + '.mp3';
}

function getDownloadURI() {
	return 'http://www.everyayah.com/data/'+ reciter+ '/'+ sura+ aya+ '.mp3';
}

function playLocalFile(fileName) {
	console.log('Playing local file...');
	console.log(fileName.nativeURL);
	var media = new Media(fileName.nativeURL, onMediaComplete, onMediaError, onMediaStatus);
	media.play();
}

function onMediaError(e) {
    console.log('Media Error');
    console.log(JSON.stringify(e));
}

function onMediaComplete() {
    console.log('Media completed');
}

function onMediaStatus(entry) {
    console.log('Media status');
    console.log(JSON.stringify(entry));
}

function downloadFile() {
	var fileTransfer = new FileTransfer();
	var localTargetFile = getLocalFile();

	console.log("About to start file download...");
	console.log("localTargetFile: " + localTargetFile);

	fileTransfer.download(
		getDownloadURI(),
		localTargetFile,
		function(entry) {
			console.log("Successfully file downloaded")
		},
		function(error) {
			console.log("download error source " + error.source);
	        console.log("download error target " + error.target);
	        console.log("download error code" + error.code);
		}
	);
}

function file_test() {
	console.log(cordova.file.dataDirectory + 'mp3/');
}