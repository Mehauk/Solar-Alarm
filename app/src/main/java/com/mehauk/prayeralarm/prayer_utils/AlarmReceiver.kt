package com.mehauk.prayeralarm.prayer_utils

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.mehauk.prayeralarm.prayer_utils.PrayerManager.EXTRA_PRAYER_NAME
import com.mehauk.prayeralarm.prayer_utils.PrayerManager.EXTRA_TYPE
import com.mehauk.prayeralarm.prayer_utils.PrayerManager.TYPE_DAILY_UPDATE
import com.mehauk.prayeralarm.prayer_utils.PrayerManager.TYPE_PRAYER

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val type = intent.getStringExtra(EXTRA_TYPE)

        if (type == TYPE_PRAYER) {
            val prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "Prayer"
            
            val settings = PrayerSettings(context)
            val isMuted = settings.isPrayerMuted(prayerName)
            
            println("Alarm received for: $prayerName (Muted: $isMuted)")
            NotificationHelper.showNotification(context, prayerName, shouldPlaySound = !isMuted)
        } else if (type == TYPE_DAILY_UPDATE) {
            println("Daily update received. Rescheduling alarms.")
            PrayerManager.scheduleDailyWork(context)
        }
    }
}
