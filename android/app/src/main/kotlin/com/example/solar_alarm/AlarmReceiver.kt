package com.example.solar_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import com.example.solar_alarm.utils.Alarm
import com.example.solar_alarm.utils.Constants.Companion.DAILY_PRAYERS
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET
import com.example.solar_alarm.utils.Prayer
import org.json.JSONObject

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        println("AlarmReceiver " + SystemClock.currentThreadTimeMillis().toString() + " in com.example.solar_alarm.AlarmReceiver onReceive()")
        val alarmName = intent.getStringExtra("alarmName")

        Alarm.getAlarm(alarmName!!, context)?.let {
            val alarm = JSONObject(it)
            val alarmIntent = Intent(context, AlarmActivity::class.java)
            val alarmTime = alarm.getString("timeInMillis").toLong()
            val alarmStatuses = alarm.getJSONArray("statuses")
            val statusList = mutableListOf<String>()

            for (i in 0 until alarmStatuses.length()) {
                val statusObject = alarmStatuses.getJSONObject(i)
                val runtimeType = statusObject.getString("runtimeType")
                statusList.add(runtimeType)
            }

            val alarmSoundStatus = "sound" in statusList
            val alarmVibrateStatus = "vibrate" in statusList

            alarmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)

            alarmIntent.putExtra("alarmName", alarmName)
            alarmIntent.putExtra("alarmTime", alarmTime)
            alarmIntent.putExtra("alarmSoundStatus", alarmSoundStatus)
            alarmIntent.putExtra("alarmVibrateStatus", alarmVibrateStatus)

            context.startActivity(alarmIntent)

            val repeatInterval = alarm.optString("repeatInterval").toLongOrNull()

            if (repeatInterval != null && repeatInterval > 1000L) {
                alarm.put(
                    "timeInMillis",
                    alarm.getString("timeInMillis").toLong() + repeatInterval
                )
                println("alarm $alarmName set to reset $repeatInterval")
                Alarm.setAlarm(alarm.toString(), context)
            } else {
                alarm.put("enabled", false)
                Alarm.setAlarm(alarm.toString(), context)
            }
        } ?: {
            when (alarmName) {
                PRAYER_RESET -> {
                    Prayer.schedulePrayerAlarms(context)
                }
                in DAILY_PRAYERS -> {


                }
                else -> {}
            }
        }
    }
}