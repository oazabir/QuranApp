package com.quranapp.android.service;

import android.util.Log;

import com.squareup.otto.Bus;
import com.squareup.otto.ThreadEnforcer;

public class BusFactory {

    private static final String TAG = BusFactory.class.getName();
    private static Bus bus;

    private static Bus getBus() {
        if (bus == null) {
            bus = new Bus(ThreadEnforcer.ANY);
        }

        return bus;
    }

    public static boolean register(Object obj) {
        if (obj == null) return false;

        getBus().register(obj);
        return true;
    }

    public static boolean unregister(Object obj) {
        if (obj == null) return false;

        try {
            getBus().unregister(obj);
        } catch (IllegalArgumentException e) {
            Log.e(TAG, " error while unregistering from BUS: " + e.getMessage());
            return false;
        }
        return true;
    }

    public static void post(Object o) {
        getBus().post(o);
    }
}
