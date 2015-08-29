package com.quranapp.android;

import android.app.Application;
import android.content.Context;

import com.quranapp.android.util.OkHttpClientFactory;

public class QuranApp extends Application {

    private static QuranApp instance;
    @Override
    public void onCreate() {
        super.onCreate();

        instance = this;
        OkHttpClientFactory.init(this);
    }

    public static Context getContext() {
        return instance;
    }
}
