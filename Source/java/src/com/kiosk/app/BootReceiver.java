package com.kiosk.app;

import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.Context;

public class BootReceiver extends BroadcastReceiver {
    
    @Override
    public void onReceive(Context context, Intent intent) {
        switch (intent.getAction()) {
            case Intent.ACTION_BOOT_COMPLETED:
				Intent launchintent = new Intent();
				launchintent.setClassName(context, "com.embarcadero.firemonkey.FMXNativeActivity");           
				launchintent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				context.startActivity(launchintent);  
                break;
        }
    }
}