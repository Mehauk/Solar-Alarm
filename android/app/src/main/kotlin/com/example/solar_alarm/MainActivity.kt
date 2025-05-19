package com.example.solar_alarm

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log

class MainActivity : FlutterActivity() {
    private val alarmChannel = "com.example.solar_alarm/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, alarmChannel)
            .setMethodCallHandler {
                call, result ->
                when (call.method) {
                    "setAlarm" -> {
                        val timeInMillis = (call.arguments as Map<*, *>)["time"]!! as Long
                        setAlarm(timeInMillis)
                        result.success(null)
                    }
                }
            }
    }

    private fun setAlarm(timeInMillis: Long) {
        val context = applicationContext
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
