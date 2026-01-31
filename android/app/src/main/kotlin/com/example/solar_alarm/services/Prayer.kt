package com.example.solar_alarm.services

import android.content.Context
import androidx.core.content.edit
import com.example.solar_alarm.utils.Constants
import com.example.solar_alarm.utils.Constants.Companion.DAILY_PRAYERS
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET
import com.example.solar_alarm.utils.PrayTime
import org.json.JSONObject
import java.util.Calendar

class Prayer(val context: Context) {
    private val alarmService: Alarm = Alarm(context)

    private fun getPrayerMillis(
        latitudeDegrees: Double,
        longitudeDegrees: Double,
    ): Map<String, Long> {
        // Create an instance of the PrayTime class
        val prayTime = PrayTime()

        // Configure the PrayTime instance
        prayTime.timeFormat = prayTime.time24
        prayTime.calcMethod = prayTime.mwl // Example: Muslim World League
        prayTime.asrJuristic = prayTime.shafii
        prayTime.adjustHighLats = prayTime.angleBased

        // Get the current date
        val calendar = Calendar.getInstance()
        val year = calendar.get(Calendar.YEAR)
        val month = calendar.get(Calendar.MONTH) + 1 // Months are 0-based
        val day = calendar.get(Calendar.DAY_OF_MONTH)

        val timezoneOffsetHours =
            calendar.get(Calendar.ZONE_OFFSET) + calendar.get(Calendar.DST_OFFSET)
        val timezone = timezoneOffsetHours.toDouble() / (1000 * 60 * 60)

        // Calculate prayer times
        val prayerTimes =
            prayTime.getDatePrayerTimes(
                year,
                month,
                day,
                latitudeDegrees,
                longitudeDegrees,
                timezone,
            )

        // Convert prayer times to milliseconds
        val startOfDayMillis =
            calendar
                .apply {
                    set(Calendar.HOUR_OF_DAY, 0)
                    set(Calendar.MINUTE, 0)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }.timeInMillis

        // Map prayer times to names and return
        return prayerTimes
            .mapIndexed { index, time ->
                val millis = startOfDayMillis + time
                prayTime.timeNames[index] to millis
            }.toMap()
    }

    fun updatePrayerSettings(name: String, status: String) {
        val prefs = context.getSharedPreferences("prayer_settings_prefs", Context.MODE_PRIVATE)
        val statusKey = "alarm_status_$name"
        prefs.edit { putString(statusKey, status) }
    }

    fun getPrayerTimesFromLocation(
        latitude: Double? = null,
        longitude: Double? = null,
    ): Map<String, Any> {
        val prefs = context.getSharedPreferences("prayer_settings_prefs", Context.MODE_PRIVATE)
        val prayerTimes = getPrayerMillis(
            latitude ?: Constants.DEFAULT_LATITUDE,
            longitude ?: Constants.DEFAULT_LONGITUDE
        )

        val result = mutableMapOf<String, Any>()
        result.putAll(prayerTimes)

        val statuses = mutableMapOf<String, String>()
        for (prayer in prayerTimes.keys) {
            val statusKey = "alarm_status_$prayer"
            val status = prefs.getString(statusKey, "disabled") ?: "disabled"
            statuses[prayer] = status
        }

        result["__statuses__"] = statuses
        return result
    }

    fun schedulePrayerAlarms() {
        val prayerTimes = getPrayerTimesFromLocation()
        val currentTime = System.currentTimeMillis()
        DAILY_PRAYERS.forEach { name ->
            val time = prayerTimes[name] as Long
            val status = (prayerTimes["__statuses__"] as Map<*, *>)[name] as String
            if (time > currentTime) {
                val prayerMap =
                    buildMap {
                        put("name", name)
                        put("timeInMillis", time.toString())
                        put("enabled", status != "disabled")
                        if (status == "sound") {
                            put(
                                "statuses",
                                arrayOf(
                                    JSONObject("{\"runtimeType\": \"sound\"}"),
                                    JSONObject("{\"runtimeType\": \"vibrate\"}"),
                                ),
                            )
                        }
                        if (status == "vibrate") {
                            put("statuses", arrayOf(JSONObject("{\"runtimeType\": \"vibrate\"}")))
                        }
                    }

                alarmService.setAlarm(
                    JSONObject(prayerMap).toString(),
                    save = false,
                    asExtra = true,
                )
            }
        }

        // Set an alarm at the start of the next day (00:00:00)
        val calendar =
            Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 5)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
        val startOfNextDayMillis = calendar.timeInMillis
        val map =
            mapOf(
                "name" to PRAYER_RESET,
                "timeInMillis" to startOfNextDayMillis.toString(),
                "enabled" to true,
            )
        alarmService.setAlarm(JSONObject(map).toString(), false)
    }
}
