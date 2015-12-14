//The directory to store data
var store;
//media player
var media;

var reciter;
var sura = -1;
var aya = -1;
var defaultReciter = 'Husary_128kbps';

function playDefault(s, a) {
	play(defaultReciter, s, a);
}

function play(r, s, a) {
	reciter = r;
	sura = s;
	aya = a;
	
	initStoreLocation();
	window.resolveLocalFileSystemURL(getLocalFile(), playLocalFile, downloadFile);
}


function playFromCurrentPosition() {
	if(sura == -1 || aya == -1) {
		console.log("Current positino unknown");
		return;
	}

	if(store == null) {
		initStoreLocation();
	}

	window.resolveLocalFileSystemURL(getLocalFile(), playLocalFile, downloadFile);	
}

function initStoreLocation() {
	store = cordova.file.dataDirectory + 'mp3';
}

function threeDigits(num) {
	var temp = '000'+ num;
	return temp.substr(temp.length-3);
}

function getLocalFile() {
	var localFile = store + '/' + reciter + '/' + threeDigits(sura) + '/' + threeDigits(aya) + '.mp3';
	console.log("Local file: " + localFile);
	return localFile;
}

function getDownloadURI() {
	return 'http://www.everyayah.com/data/' + reciter + '/' + threeDigits(sura) + threeDigits(aya) + '.mp3';
}

function playLocalFile(fileName) {
	console.log('Playing from local file system');
	console.log('file: ' + fileName.toInternalURL());
	if(media != null)
		media.release();

	media = new Media(fileName.toInternalURL(), onMediaComplete, onMediaError, onMediaStatus);
	media.play();
}

function onMediaError(e) {
    console.log('Media Error');
    console.log(JSON.stringify(e));
}

function onMediaComplete() {
    console.log('Play completed for sura: ' + sura + ' aya: ' + aya);
    aya += 1;
    playFromCurrentPosition();
}

function onMediaStatus(entry) {
    console.log('Media status');
    console.log(JSON.stringify(entry));
}

function downloadFile(entry) {
	console.log(entry)
	var fileTransfer = new FileTransfer();
	var localTargetFile = getLocalFile();

	console.log("About to start file download...");
	console.log("localTargetFile: " + localTargetFile);

	fileTransfer.download(
		getDownloadURI(),
		localTargetFile,
		function(entry) {
			console.log("Successfully file downloaded");
			playFromCurrentPosition();
		},
		function(error) {
			console.log("download error source " + error.source);
	        console.log("download error target " + error.target);
	        console.log("download error code" + error.code);
		}
	);
}

function cordova_file_test() {
	console.log(cordova.file.dataDirectory + 'mp3/');
}