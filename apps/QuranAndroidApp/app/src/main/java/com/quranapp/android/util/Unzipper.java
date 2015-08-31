package com.quranapp.android.util;

import android.util.Log;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

public class Unzipper {

    private static final String TAG = Unzipper.class.getName();
    private String fileName;
    private String filePath;
    private String destinationPath;

    public Unzipper(String fileName, String filePath, String destinationPath) {
        this.fileName = fileName;
        this.filePath = filePath;
        this.destinationPath = destinationPath;
    }

    public void unzip() {
        Log.d(TAG, "Unzip: " + fileName + " -> " + destinationPath);
        File archive = new File(makeFullPath());
        try {
            ZipFile zipfile = new ZipFile(archive);
            for (Enumeration e = zipfile.entries(); e.hasMoreElements(); ) {
                ZipEntry entry = (ZipEntry) e.nextElement();
                if (!entry.getName().contains(".git")) {
                    unzipEntry(zipfile, entry, destinationPath);
                }
            }
        } catch (Exception e) {
            Log.e(TAG,"Error unzipping: " + archive, e);
        }
    }

    private String makeFullPath() {
        return filePath + File.separator + fileName;
    }

    private void unzipEntry(ZipFile zipfile, ZipEntry entry, String outputDir) throws IOException {

        if (entry.getName().startsWith("__") || entry.getName().startsWith(".")) {
            return;
        }

        if (entry.isDirectory()) {
            createDir(new File(outputDir, entry.getName()));
            return;
        }

        File outputFile = new File(outputDir, entry.getName());
        if (!outputFile.getParentFile().exists()) {
            createDir(outputFile.getParentFile());
        }

        Log.d(TAG, "Extracting: " + entry + " to:" + outputFile.getAbsolutePath());
        BufferedInputStream inputStream = new BufferedInputStream(zipfile.getInputStream(entry));
        BufferedOutputStream outputStream = new BufferedOutputStream(new FileOutputStream(outputFile));

        try {
            StreamHelper.copyStream(inputStream, outputStream);
        } finally {
            outputStream.close();
            inputStream.close();
        }
    }

    private void createDir(File dir) {
        if (dir.exists()) {
            return;
        }
        Log.d(TAG, "Creating dir: " + dir.getName());
        if (!dir.mkdirs()) {
            throw new RuntimeException("Error creating directory: " + dir);
        }
    }
}
