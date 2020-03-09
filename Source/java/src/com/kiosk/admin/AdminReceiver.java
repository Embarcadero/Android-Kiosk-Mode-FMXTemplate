package com.kiosk.admin;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class AdminReceiver extends DeviceAdminReceiver {
    @Override
    public void onLockTaskModeEntering(Context context, Intent intent, String pkg) {
        Log.d("KIOSK", "onLockTaskModeEntering ADMIN");
    }
}