package com.example.solar_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.solar_alarm.utils.Alarm

class  BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            println("BootReceiver: Device rebooted, rescheduling alarms...")

            // Call your alarm rescheduling logic
            Alarm.rescheduleAllAlarms(context)
        }
    }
}
