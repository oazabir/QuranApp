package com.quranapp.android.service;

import android.app.IntentService;
import android.content.Intent;
import android.util.Log;

import com.quranapp.android.QuranApp;
import com.quranapp.android.util.Constants;
import com.quranapp.android.util.IntentExtraKeys;
import com.quranapp.android.util.OkHttpClientFactory;
import com.quranapp.android.util.Unzipper;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import java.io.File;
import java.io.IOException;

import okio.BufferedSink;
import okio.Okio;

public class BundleDownloadService extends IntentService {


    private static final String TAG = BundleDownloadService.class.getName();

    public BundleDownloadService() {
        super(BundleDownloadService.class.getName());
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        boolean unpackAfterDownload = intent.getBooleanExtra(IntentExtraKeys.UNPACK_AFTER_DOWNLOAD, false);
        boolean unpackOnly = intent.getBooleanExtra(IntentExtraKeys.UNPACK_DOWNLOADED_BUNDLE_ONLY, false);
        if (unpackOnly) {
            unpackDownloadedBundle();
            return;
        }

        boolean downloadSuccess = downloadBundle();
        if (downloadSuccess && unpackAfterDownload) {
            unpackDownloadedBundle();
        }
    }

    private boolean downloadBundle() {
        try {
            File downloadedFile = new File(QuranApp.getContext().getCacheDir(), "bundle.zip");
            Request request = new Request.Builder()
                    .url(Constants.BUNDLE_DOWNLOAD_URL)
                    .build();

            Response response = OkHttpClientFactory.getClient().newCall(request).execute();
            BufferedSink sink = Okio.buffer(Okio.sink(downloadedFile));
            sink.writeAll(response.body().source());
            sink.close();
            return true;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }

    private void unpackDownloadedBundle() {
        Log.d(TAG, "Unzipping....");
        Unzipper unzipper = new Unzipper("bundle.zip", QuranApp.getContext().getCacheDir().getAbsolutePath(), new File(QuranApp.getContext().getFilesDir(), "www").getAbsolutePath());
        unzipper.unzip();
        Log.d(TAG, "Unzip completed");
    }
}
