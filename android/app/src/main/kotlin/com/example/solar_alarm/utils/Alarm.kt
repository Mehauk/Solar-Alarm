package com.example.solar_alarm.utils

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import com.example.solar_alarm.AlarmReceiver
import com.example.solar_alarm.utils.Constants.Companion.ALARM_PREFIX
import com.example.solar_alarm.utils.Constants.Companion.DAYS_OF_THE_WEEK
import com.example.solar_alarm.utils.Constants.Companion.ONE_DAY_MILLIS
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
            var timeInMillis = alarm.getString("timeInMillis").toLong()

            val alarmEnabled = alarm.getBoolean("enabled")

            var delayedUntil = 0L
            val statuses = alarm.optJSONArray("statuses")
            if (statuses != null) {
                for (i in 0 until statuses.length()) {
                    val status = statuses.getJSONObject(i)
                    if (status["runtimeType"] == "delayed") {
                        delayedUntil = status.getLong("delayedUntil")
                    }
                }
            }

            val diff = delayedUntil - timeInMillis

            if (diff > 0) {
                val days = Math.floorDiv(diff, ONE_DAY_MILLIS)
                timeInMillis += days * ONE_DAY_MILLIS

                if (timeInMillis < delayedUntil) {
                    timeInMillis += ONE_DAY_MILLIS
                }
            }

            alarm.put("timeInMillis", timeInMillis)
            getNextAlarmTimeForRepeatDays(alarm)?.let {
                timeInMillis = it
            }

            if (alarmEnabled) {
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
            }

            if (save) getAlarmPrefs(context).edit().putString("$ALARM_PREFIX$alarmName", alarmJson).apply()
        }

        fun getNextAlarmTimeForRepeatDays(alarm: JSONObject): Long? {
            alarm.optJSONArray("repeatDays")?.let {repeatDays ->
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
                        if (daysUntil == 0) daysUntil = 7 // Don't repeat today, go to next week
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