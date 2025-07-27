package com.example.solar_alarm.utils

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import com.example.solar_alarm.AlarmReceiver
import com.example.solar_alarm.utils.Constants.Companion.ALARM_PREFIX
import com.example.solar_alarm.utils.Constants.Companion.DAYS_OF_THE_WEEK
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET
import org.json.JSONObject
import java.util.UUID

class Alarm {
    companion object {
        private fun getAlarmPrefs(context: Context): SharedPreferences {
            return context.getSharedPreferences("alarm_prefs", Context.MODE_PRIVATE)
        }

        fun setAlarm(alarmJson: String, context: Context, save: Boolean = true, asExtra: Boolean = false, unique: Boolean = false) {
            val alarm = JSONObject(alarmJson)
            val alarmName = alarm.getString("name")
            cancelAlarm(alarmName, context)
            println("setAlarm: Setting alarm for $alarmName with data: $alarmJson")
            var timeInMillis = alarm.getString("timeInMillis").toLong()

            val alarmEnabled = alarm.getBoolean("enabled")
            println("The alarm $alarmName is enabled = $alarmEnabled")

            println("setAlarm: Initial timeInMillis for $alarmName: $timeInMillis")

            alarm.put("timeInMillis", timeInMillis)
            getNextAlarmTimeForRepeatDays(alarm, setToday = true)?.let {
                println("setAlarm: getNextAlarmTimeForRepeatDays returned $it for $alarmName, updating timeInMillis")
                timeInMillis = it
            }

            if (alarmEnabled) {
                println("setAlarm: Alarm $alarmName is enabled, scheduling at $timeInMillis (" + java.util.Date(timeInMillis) + ")")
                val intent = Intent(context, AlarmReceiver::class.java)
                intent.putExtra("alarmName", alarmName)

                if (asExtra) {
                    intent.putExtra("alarmJson", alarmJson)
                }

                var hash: Int = alarmName.hashCode()
                if (unique) {
                    hash =  UUID.randomUUID().hashCode()
                }

                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    hash,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

                val aci = AlarmManager.AlarmClockInfo(timeInMillis, pendingIntent)
                alarmManager.setAlarmClock(aci, pendingIntent)
            } else {
                println("setAlarm: Alarm $alarmName is disabled, not scheduling.")
            }

            if (save) println("setAlarm: Saving alarm $alarmName to preferences")
            if (save) saveAlarm(alarmName, alarmJson, context)
        }

        private fun saveAlarm(alarmName:String, alarmJson: String, context: Context) {
            getAlarmPrefs(context).edit().putString("$ALARM_PREFIX$alarmName", alarmJson).apply()
        }

        fun getNextAlarmTimeForRepeatDays(alarm: JSONObject, setToday: Boolean = false): Long? {
            alarm.optJSONArray("repeatDays")?.let {repeatDays ->
                if (repeatDays.length() == 0) return null
                val calendar = java.util.Calendar.getInstance()
                calendar.timeInMillis = alarm.getString("timeInMillis").toLong()
                val currentDayIndex = calendar.get(java.util.Calendar.DAY_OF_WEEK) - 1 // 0 = Sunday

                // Find the next day in repeatDays
                var minDaysUntil = 8
                for (i in 0 until repeatDays.length()) {
                    val day = repeatDays.getString(i).lowercase()
                    val dayIndex = DAYS_OF_THE_WEEK.indexOf(day)
                    if (dayIndex != -1) {
                        var daysUntil = (dayIndex - currentDayIndex + 7) % 7
                        if (daysUntil == 0 && !setToday) daysUntil = 7 // Don't repeat today, go to next week
                        if (daysUntil < minDaysUntil) minDaysUntil = daysUntil
                    }
                }
                // Set next alarm time
                calendar.add(java.util.Calendar.DAY_OF_YEAR, minDaysUntil)
                return calendar.timeInMillis
            }
           return null
        }

        fun getAlarm(alarmName: String, context: Context): String? {
            return getAlarmPrefs(context).getString("$ALARM_PREFIX$alarmName", null)
        }

        // Formatted for dart channel
        fun getAllAlarms(context: Context): List<String> {
            val prefs = getAlarmPrefs(context)
            return prefs.all
                .filter { (k, v) -> k.startsWith(ALARM_PREFIX) && !k.contains(PRAYER_RESET) && v is String }
                .mapNotNull { (_, v) ->
                    (v as? String)?.let { json -> JSONObject(json).toString() }
                }
        }

        fun cancelAlarm(alarmName: String, context: Context) {
            println("cancelAlarm: Cancelling alarm $alarmName")
            val intent = Intent(context, AlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmName.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            alarmManager.cancel(pendingIntent)

            getAlarmPrefs(context).edit().remove("$ALARM_PREFIX$alarmName").apply()

            println("Alarm $alarmName canceled and removed from preferences.")
        }

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

                    else {
                        println("Alarm Skipped expired alarm: $alarmName")
                    }
                }
            }
        }
    }
}