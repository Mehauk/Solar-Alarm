package com.example.solar_alarm

import com.example.solar_alarm.utils.Alarm.Companion.setAlarm
import com.example.solar_alarm.utils.Alarm.Companion.getAllAlarms
import com.example.solar_alarm.utils.Alarm.Companion.cancelAlarm
import com.example.solar_alarm.utils.Prayer.Companion.getPrayerTimesWithSettings
import com.example.solar_alarm.utils.Prayer.Companion.schedulePrayerAlarms
import com.example.solar_alarm.utils.Prayer.Companion.updatePrayerSettings
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
                            val alarmMap = call.arguments as Map<*, *>
                            val alarmJson = org.json.JSONObject(alarmMap).toString()
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
                            getPrayerTimesWithSettings(this) { prayerTimes ->
                                prayerTimes?.let {
                                    schedulePrayerAlarms(context, prayerTimes)
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

                        "updatePrayerSetting" -> {
                            val args = call.arguments as Map<*, *>
                            val prayerName = args["name"]!! as String
                            val prayerStatus = args["status"]!! as String
                            updatePrayerSettings(context, prayerName, prayerStatus)
                            result.success(null)
                        }

                    }
                }
    }
}
