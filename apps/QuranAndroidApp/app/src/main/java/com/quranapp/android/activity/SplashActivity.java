package com.quranapp.android.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.widget.TextView;

import com.quranapp.android.R;
import com.quranapp.android.service.BundleDownloadService;
import com.quranapp.android.service.BusFactory;
import com.quranapp.android.util.IntentExtraKeys;
import com.quranapp.android.util.PreferenceHelper;
import com.squareup.otto.Subscribe;

public class SplashActivity extends AppCompatActivity {

    private final String TAG = SplashActivity.class.getName();
    private TextView progressText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        progressText = (TextView) findViewById(R.id.progress_text);

        if (!new PreferenceHelper().hasBundleDownloadBefore()) {
            downloadBundle(true);
        } else {
            checkNewBundleAvailability();
        }

        BusFactory.register(this);
    }

    private void downloadBundle(boolean unpackAfterDownload) {
        Intent intent = new Intent(this, BundleDownloadService.class);
        intent.putExtra(IntentExtraKeys.UNPACK_AFTER_DOWNLOAD, unpackAfterDownload);
        startService(intent);
    }

    private void checkNewBundleAvailability() {
        //TODO
        killMeAndStartQuranReadingActivity();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        BusFactory.unregister(this);
    }

    @Subscribe
    public void statuspUpdate(final BundleDownloadService.ProgressStatus progressStatus) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                updateStatus(progressStatus);
            }
        });
    }

    private void updateStatus(BundleDownloadService.ProgressStatus progressStatus) {
        switch (progressStatus.status) {
            case DOWNLOADING:
                progressText.setText("Downloading data...");
                break;
            case UNPAKING:
                progressText.setText("Processing data...");
                break;
            case COMPLETE:
            default:
                killMeAndStartQuranReadingActivity();
        }

        Log.d(TAG, "Status update: " + progressStatus.status.name());
    }

    private void killMeAndStartQuranReadingActivity() {
        finish();
        startActivity(new Intent(this, ReadingActivity.class));
    }
}
