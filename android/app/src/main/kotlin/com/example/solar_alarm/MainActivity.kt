package com.example.solar_alarm

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.solar_alarm.utils.Alarm.Companion.setAlarm

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
                        val context = applicationContext
                        setAlarm(timeInMillis, context)
                        result.success(null)
                    }
                }
            }
    }
}
