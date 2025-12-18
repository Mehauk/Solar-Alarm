package com.mehauk.prayeralarm.prayer_utils

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            println("Boot completed. Rescheduling alarms.")
            PrayerManager.scheduleDailyWork(context)
        }
    }
}
