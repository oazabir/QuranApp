package com.quranapp.android.util;

import android.content.Context;
import android.content.SharedPreferences;

import com.quranapp.android.QuranApp;

public class PreferenceHelper {

    private final String LAST_BUNDLE_UPDATE = "last_bundle_update";

    private SharedPreferences getPreference() {
        return QuranApp.getContext().getSharedPreferences("app_settings_preference", Context.MODE_PRIVATE);
    }

    public long getLastDataBundleUpdateTime() {
        return getLong(LAST_BUNDLE_UPDATE);
    }

    public boolean hasBundleDownloadBefore() {
        return getLastDataBundleUpdateTime() != 0;
    }

    public long getLong(String key) {
        return getPreference().getLong(key, 0L);
    }
}
