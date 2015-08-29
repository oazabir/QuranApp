package com.quranapp.android.activity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import com.quranapp.android.R;
import com.quranapp.android.service.BundleDownloadService;
import com.quranapp.android.util.IntentExtraKeys;
import com.quranapp.android.util.PreferenceHelper;

public class SplashActivity extends AppCompatActivity {

    private final String TAG = SplashActivity.class.getName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        if (!new PreferenceHelper().hasBundleDownloadBefore()) {
            downloadBundle(true);
        } else {
            checkNewBundleAvailability();
        }
    }

    private void downloadBundle(boolean unpackAfterDownload) {
        Intent intent = new Intent(this, BundleDownloadService.class);
        intent.putExtra(IntentExtraKeys.UNPACK_AFTER_DOWNLOAD, unpackAfterDownload);
        startService(intent);
    }

    private void checkNewBundleAvailability() {

    }
}
