package com.example.solar_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import com.example.solar_alarm.utils.Alarm
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET
import com.example.solar_alarm.utils.Prayer

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        println("AlarmReceiver " + SystemClock.currentThreadTimeMillis().toString() + " in com.example.solar_alarm.AlarmReceiver onReceive()")
        val alarmName = intent.getStringExtra("alarmName")
        val alarmTime = intent.getLongExtra("alarmTime", 0)
        val repeatInterval = intent.getLongExtra("alarmRepeatInterval", 0)

        if (alarmName!!.contains(PRAYER_RESET)) {
            Prayer.setPrayerAlarms(context)
        } else {
            val alarmIntent = Intent(context, AlarmActivity::class.java)
            alarmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            alarmIntent.putExtra("alarmName", alarmName)
            alarmIntent.putExtra("alarmTime", alarmTime)
            context.startActivity(alarmIntent)
        }

        println("alarm $alarmName set to reset $repeatInterval")
        if (repeatInterval > 1000L) {
            Alarm.setAlarm(alarmTime + repeatInterval, alarmName, context, repeatInterval)
        }
    }
}