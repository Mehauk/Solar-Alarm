package com.example.solar_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmReceiver", SystemClock.currentThreadTimeMillis().toString() + " in com.example.solar_alarm.AlarmReceiver onReceive()")
        val alarmIntent = Intent(context, AlarmActivity::class.java)
        alarmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        alarmIntent.putExtra("alarmName", intent.getStringExtra("alarmName"));
        context.startActivity(alarmIntent)
    }
}