package com.example.solar_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.solar_alarm.utils.Alarm
import com.example.solar_alarm.utils.FileLogger
import com.example.solar_alarm.utils.Prayer

class  BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            FileLogger.append(context, "BootReceiver", "Device rebooted, rescheduling alarms...")

            // Call your alarm rescheduling logic
            Alarm.rescheduleAllAlarms(context)

            Prayer.getPrayerTimesWithSettings(context) {prayerTimings ->
                prayerTimings?.let {
                    Prayer.schedulePrayerAlarms(context, it)
                }
            }
        }
    }
}
