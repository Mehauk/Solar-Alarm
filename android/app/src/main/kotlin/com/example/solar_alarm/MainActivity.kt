package com.example.solar_alarm

import com.example.solar_alarm.utils.Alarm.Companion.setAlarm
import com.example.solar_alarm.utils.Prayer.Companion.getPrayerMillis
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val alarmChannel = "com.example.solar_alarm/main_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, alarmChannel)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "setAlarm" -> {
                            val args = call.arguments as Map<*, *>
                            val timeInMillis = args["time"]!! as Long
                            val alarmName = args["name"]!! as String
                            val context = applicationContext
                            setAlarm(timeInMillis, alarmName, context)
                            result.success(null)
                        }
                        "getPrayerTimes" -> {
                            val args = call.arguments as Map<*, *>
                            val timeInMillis = args["date"]!! as Long
                            val prayerTimes = getPrayerMillis(53.5461, -113.4938, timeInMillis)
                            result.success(prayerTimes)
                        }
                    }
                }
    }
}
