package com.example.solar_alarm.utils

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import com.example.solar_alarm.AlarmReceiver
import com.example.solar_alarm.utils.Constants.Companion.ALARM_PREFIX
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET
import org.json.JSONObject

class Alarm {
    companion object {
        private fun getAlarmPrefs(context: Context): SharedPreferences {
            return context.getSharedPreferences("alarm_prefs", Context.MODE_PRIVATE)
        }

        fun setAlarm(alarmJson: String, context: Context, save: Boolean = true) {
            val intent = Intent(context, AlarmReceiver::class.java)

            val alarm = JSONObject(alarmJson)
            val alarmName = alarm.getString("name")
            val timeInMillis = alarm.getString("timeInMillis").toLong()

            intent.putExtra("alarmName", alarmName)

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmName.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            val aci = AlarmManager.AlarmClockInfo(timeInMillis, pendingIntent)
            alarmManager.setAlarmClock(aci, pendingIntent)

            if (save) getAlarmPrefs(context).edit().putString("$ALARM_PREFIX$alarmName", alarmJson).apply()
        }

        fun getAlarm(alarmName: String, context: Context): String? {
            return getAlarmPrefs(context).getString("$ALARM_PREFIX$alarmName", null)
        }

        fun getAllAlarms(context: Context): List<String> {
            val prefs = getAlarmPrefs(context)
            return prefs.all
                .filter { (k, v) -> k.startsWith(ALARM_PREFIX) && !k.contains(PRAYER_RESET) && v is String }
                .mapNotNull { (_, v) -> v as? String }
        }

        fun cancelAlarm(alarmName: String, context: Context) {
            val intent = Intent(context, AlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmName.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.cancel(pendingIntent)

            getAlarmPrefs(context).edit().remove(alarmName).apply()

            println("Alarm $alarmName canceled and removed from preferences.")
        }

        // NEEDS WORK!!!!
        fun disableAlarm(alarmName: String, context: Context) {

        }

        // NEEDS WORK!!!!
        fun rescheduleAllAlarms(context: Context) {
            val prefs = getAlarmPrefs(context)
            val allEntries = prefs.all

            for ((key, value) in allEntries) {

                if (key.startsWith(ALARM_PREFIX) && value is String) {
                    val alarmName = key.removePrefix(ALARM_PREFIX)
                    val timeInMillis = JSONObject(value).getString("timeInMillis").toLong()

                    if (System.currentTimeMillis() < timeInMillis) {
                        setAlarm(value, context)
                        println("Alarm Rescheduled alarm: $alarmName")
                    }

                    else if (key.contains(PRAYER_RESET)) {
                        setAlarm(value, context)
                        println("Alarm Rescheduled prayer reset: $alarmName")
                    }

                    else {
                        println("Alarm Skipped expired alarm: $alarmName")
                    }
                }
            }
        }
    }
}