package com.example.solar_alarm.utils

import android.annotation.SuppressLint
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import com.example.solar_alarm.AlarmReceiver

class Alarm {
    companion object {
        @SuppressLint("MissingPermission")
        fun setAlarm(timeInMillis: Long, context: Context) {
            val intent = Intent(context, AlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

            val aci = AlarmManager.AlarmClockInfo(timeInMillis, pendingIntent)
            alarmManager.setAlarmClock(aci, pendingIntent)

            Log.d("MainActivity", "Alarm set for: $timeInMillis")
        }
    }
}