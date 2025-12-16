package com.example.solar_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.solar_alarm.utils.Alarm
import com.example.solar_alarm.utils.FileLogger
import com.example.solar_alarm.utils.Alarm.Companion.getNextAlarmTimeForRepeatDays
import com.example.solar_alarm.utils.Constants.Companion.DAILY_PRAYERS
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET
import com.example.solar_alarm.utils.Prayer
import org.json.JSONObject

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
    FileLogger.append(context, "AlarmReceiver", "Received alarm broadcast at ${System.currentTimeMillis()}")
        val alarmName = intent.getStringExtra("alarmName")
    FileLogger.append(context, "AlarmReceiver", "alarmName = $alarmName")

        Alarm.getAlarm(alarmName!!, context)?.let {
            FileLogger.append(context, "AlarmReceiver", "Found alarm in preferences")
            val alarm = JSONObject(it)
            startAlarmIntent(alarm, context)

            val repeatInterval = alarm.optString("repeatInterval").toLongOrNull()
            val repeatDaysNextAlarmTime = getNextAlarmTimeForRepeatDays(alarm)

            if (repeatInterval != null && repeatInterval > 1000L) {
                alarm.put(
                    "timeInMillis",
                    alarm.getString("timeInMillis").toLong() + repeatInterval
                )
                    FileLogger.append(context, "AlarmReceiver", "alarm $alarmName set to reset $repeatInterval")
                Alarm.setAlarm(alarm.toString(), context)
            } else if (repeatDaysNextAlarmTime != null) {
                alarm.put("timeInMillis", repeatDaysNextAlarmTime)
                Alarm.setAlarm(alarm.toString(), context)
            } else {
                alarm.put("enabled", false)
                Alarm.setAlarm(alarm.toString(), context)
            }
        } ?: run {
            FileLogger.append(context, "AlarmReceiver", "No alarm found for $alarmName, checking for PRAYER_RESET or DAILY_PRAYERS")
            when (alarmName) {
                PRAYER_RESET -> {
                    Prayer.getPrayerTimesWithSettings(context) {
                        times -> times?.let{Prayer.schedulePrayerAlarms(context, times)}
                    }
                }
                in DAILY_PRAYERS -> {
                    intent.getStringExtra("alarmJson")?.let{
                        val alarm = JSONObject(it)
                        startAlarmIntent(alarm, context)
                    }
                }
                else -> {}
            }
        }
    }

    private fun startAlarmIntent(alarm: JSONObject, context: Context) {
        val alarmName = alarm.getString("name")
        val alarmTime = alarm.getString("timeInMillis").toLong()
    FileLogger.append(context, "AlarmReceiver", "Preparing to launch AlarmActivity for $alarmName at $alarmTime")
        val alarmStatuses = alarm.getJSONArray("statuses")
        val statusList = mutableListOf<String>()

        for (i in 0 until alarmStatuses.length()) {
            val statusObject = alarmStatuses.getJSONObject(i)
            val runtimeType = statusObject.getString("runtimeType")
            statusList.add(runtimeType)
        }

        val alarmSoundStatus = "sound" in statusList
        val alarmVibrateStatus = "vibrate" in statusList
        val alarmDelayed = "delayed" in statusList

        val now = System.currentTimeMillis()
        if (alarmDelayed) {
            val id = statusList.indexOf("delayed")
            val delay = alarmStatuses.getJSONObject(id).getLong("delayedUntil")
            if (delay > now) return
        }

        // 5 minute grace period for alarm, since some amount of time must have elapsed from the
        // receiving the alarm and starting the intent
        if (alarmTime + 5 * 60 * 1000L > now) {
            FileLogger.append(context, "AlarmReceiver", "Starting AlarmActivity for $alarmName")
            val alarmIntent = Intent(context, AlarmActivity::class.java)
            alarmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)

            alarmIntent.putExtra("alarmName", alarmName)
            alarmIntent.putExtra("alarmTime", alarmTime)
            alarmIntent.putExtra("alarmSoundStatus", alarmSoundStatus)
            alarmIntent.putExtra("alarmVibrateStatus", alarmVibrateStatus)

            context.startActivity(alarmIntent)
        } else {
            FileLogger.append(context, "AlarmReceiver", "Alarm time has already passed for $alarmName, not starting activity")
        }
    }
}