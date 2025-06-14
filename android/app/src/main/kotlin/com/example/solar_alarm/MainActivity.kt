package com.example.solar_alarm

import com.example.solar_alarm.utils.Alarm.Companion.setAlarm
import com.example.solar_alarm.utils.Alarm.Companion.getAllAlarms
import com.example.solar_alarm.utils.Alarm.Companion.cancelAlarm
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
                            val alarmJson = args["alarmJson"]!! as String
                            setAlarm(alarmJson, context)
                            result.success(null)
                        }

                        "cancelAlarm" -> {
                            val args = call.arguments as Map<*, *>
                            val alarmName = args["name"]!! as String
                            cancelAlarm(alarmName, context)
                            result.success(null)
                        }

                        "getAllAlarms" -> {
                            result.success(getAllAlarms(context))
                        }

                        "getPrayerTimes" -> {
                            getPrayerAlarms(this) { prayerTimes ->
                                println("Prayer times 2: $prayerTimes")
                                prayerTimes?.let {
                                    result.success(it)
                                } ?: run {
                                    result.error(
                                        "LOCATION_ERROR",
                                        "Most likely failed to retrieve location",
                                        null
                                    )
                                }
                            }
                        }

                        "setPrayerAlarms" -> {
                            val prayerTimes = setPrayerAlarms(context)
                            prayerTimes?.let {
                                result.success(it)
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
