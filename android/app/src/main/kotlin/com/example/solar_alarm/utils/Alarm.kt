package com.example.solar_alarm.utils

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import com.example.solar_alarm.AlarmReceiver
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET

class Alarm {
    companion object {
        fun setAlarm(timeInMillis: Long, alarmName: String, context: Context, repeatInterval: Long?) {
            val intent = Intent(context, AlarmReceiver::class.java)
            intent.putExtra("alarmName", alarmName)
            intent.putExtra("alarmTime", timeInMillis)

            repeatInterval?.let {
                if (repeatInterval <= 0L) {
                    intent.putExtra("alarmRepeatInterval", it)
                }
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmName.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            val aci = AlarmManager.AlarmClockInfo(timeInMillis, pendingIntent)
            alarmManager.setAlarmClock(aci, pendingIntent)

            Log.d("Alarm", "Alarm set for: $timeInMillis")

            val prefs = context.getSharedPreferences("alarm_prefs", Context.MODE_PRIVATE).edit()
            prefs.putLong("alarm_time_$alarmName", timeInMillis)

            repeatInterval?.let {
                prefs.putLong("alarm_repeat_interval_$alarmName", it)
            }

            prefs.apply()
        }

        fun rescheduleAllAlarms(context: Context) {
            val prefs = context.getSharedPreferences("alarm_prefs", Context.MODE_PRIVATE)
            val allEntries = prefs.all

            for ((key, value) in allEntries) {

                if (key.startsWith("alarm_time_") && value is Long) {
                    val alarmName = key.removePrefix("alarm_time_")
                    val repeatInterval = prefs.getLong("alarm_repeat_interval_$alarmName", 0)

                    // Optional: skip expired alarms
                    if (System.currentTimeMillis() < value) {
                        setAlarm(value, alarmName, context, repeatInterval)
                        Log.d("Alarm", "Rescheduled alarm: $alarmName")
                    }

                    else if (key.contains(PRAYER_RESET)) {
                        setAlarm(value, alarmName, context, repeatInterval)
                        Log.d("Alarm", "Rescheduled prayer reset: $alarmName")
                    }

                    else {
                        Log.d("Alarm", "Skipped expired alarm: $alarmName")
                    }
                }
            }
        }
    }
}