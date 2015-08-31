package com.quranapp.android.util;

import android.content.Context;

import com.squareup.okhttp.Cache;
import com.squareup.okhttp.CacheControl;
import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.OkUrlFactory;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.TimeUnit;

public class OkHttpClientFactory {
    private static OkHttpClient client;
    private static final int CONNECTION_TIMEOUT = 20;
    private static final int READ_TIMEOUT = 20;

    private static OkUrlFactory okUrlFactory;

    public static void init(Context context) {
        if (client == null) {
            createClient(context);
            okUrlFactory = new OkUrlFactory(client);
        }
    }

    private static void createClient(Context context) {
        client = new OkHttpClient();
        client.setConnectTimeout(CONNECTION_TIMEOUT, TimeUnit.SECONDS);
        client.setReadTimeout(READ_TIMEOUT, TimeUnit.SECONDS);
    }

    public static OkHttpClient getClient() {
        if (client == null)
            throw new RuntimeException("OkHttp client has not been initialised in OkConnectionFactory");
        return client;
    }

    public static HttpURLConnection open(URL url) {
        return okUrlFactory.open(url);
    }

    public static Response getFromCache(URL url) {
        CacheControl.Builder cacheControl = new CacheControl.Builder().onlyIfCached();
        cacheControl.maxStale(Integer.MAX_VALUE, TimeUnit.MILLISECONDS);
        Request.Builder request = new Request.Builder().url(url).cacheControl(cacheControl.build());
        try {
            return client.newCall(request.build()).execute();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }
}
