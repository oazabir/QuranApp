Readme:


Play audio:
Current approach is, on receiving a request to play an audio, we look into local storage for the corresponding file. If file exists then play it using media api. If file does not exists, then we go and fetch the file and then play. On completion of the playing current file, it auto increament the aya number and repeat the process entil it reaches end of the sura (currenyly this does rely on file not found exception)

There are few methods which can trigger playing audio:
playDefault(sura, aya) : start play from the given sura and ayah with default reciter (Hussary)
play(reciter, sura, aya) : same as above except it receive an extra param for specific reciter
playFromCurrentPosition() : just play from current position


There are few hack at the moment to make things working:

1. Viewport issue: Cordova webview does not respect viewport instruction for some reason, so I had to put fix in Android and iOS separately.
	Android: In SystemWebViewEngine, inside initWebViewSettings() I added these two methods:
		settings.setUseWideViewPort(true);
		settings.setLoadWithOverviewMode(true);

	iOS: In CDVPlugin's initWithWebView() I added this method:
		self.webView.scalesPageToFit = true;