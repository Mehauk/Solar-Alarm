package com.example.solar_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.solar_alarm.services.Alarm
import com.example.solar_alarm.services.Logger
import com.example.solar_alarm.services.Prayer

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val fileLogger = Logger(context)
        val alarmService = Alarm(context)
        val prayerService = Prayer(context)

        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            fileLogger.append("BootReceiver", "Device rebooted, rescheduling alarms...")

            // Call your alarm rescheduling logic
            alarmService.rescheduleAllAlarms()
            prayerService.schedulePrayerAlarms()
        }
    }
}
