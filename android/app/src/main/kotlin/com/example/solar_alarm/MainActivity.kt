package com.example.solar_alarm

import com.example.solar_alarm.utils.Alarm.Companion.setAlarm
import com.example.solar_alarm.utils.Prayer.Companion.getPrayerAlarms
import com.example.solar_alarm.utils.Prayer.Companion.setPrayerAlarms
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val alarmChannel = "com.example.solar_alarm/main_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        val context = applicationContext

        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, alarmChannel)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "setAlarm" -> {
                            val args = call.arguments as Map<*, *>
                            val timeInMillis = args["time"]!! as Long
                            val alarmName = args["name"]!! as String
                            val repeatInterval = args["repeatInterval"] as Long?
                            setAlarm(timeInMillis, alarmName, context, repeatInterval)
                            result.success(null)
                        }

                        "getPrayerTimes" -> {
                            val prayerTimes = getPrayerAlarms(this)
                            prayerTimes?.let {
                                result.success(prayerTimes)
                            } ?: {
                                result.error(
                                    "LOCATION_ERROR",
                                    "Most likely failed to retrieve location",
                                    null
                                )
                            }
                        }

                        "setPrayerTimes" -> {
                            val prayerTimes = setPrayerAlarms(context)
                            prayerTimes?.let {
                                result.success(prayerTimes)
                            } ?: {
                                result.error(
                                    "LOCATION_ERROR",
                                    "Most likely failed to retrieve location",
                                    null
                                )
                            }
                        }
                    }
                }
    }
}
