package com.example.solar_alarm.utils

import android.app.Activity
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import java.util.Calendar
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import com.example.solar_alarm.utils.Alarm.Companion.setAlarm
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import android.provider.Settings
import com.example.solar_alarm.utils.Constants.Companion.DAILY_PRAYERS
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET
import org.json.JSONObject

class Prayer {
    companion object {
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

            val timezoneOffsetHours = calendar.get(Calendar.ZONE_OFFSET) + calendar.get(Calendar.DST_OFFSET)
            val timezone = timezoneOffsetHours.toDouble() / (1000 * 60 * 60)

            // Calculate prayer times
            val prayerTimes =
                prayTime.getDatePrayerTimes(
                    year,
                    month,
                    day,
                    latitudeDegrees,
                    longitudeDegrees,
                    timezone
                )

            // Convert prayer times to milliseconds
            val startOfDayMillis =
                calendar
                    .apply {
                        set(Calendar.HOUR_OF_DAY, 0)
                        set(Calendar.MINUTE, 0)
                        set(Calendar.SECOND, 0)
                        set(Calendar.MILLISECOND, 0)
                    }
                    .timeInMillis

            // Map prayer times to names and return
            return prayerTimes
                .mapIndexed { index, time ->
                    val millis = startOfDayMillis + time
                    prayTime.timeNames[index] to millis
                }
                .toMap()
        }

        fun updatePrayerSettings(context: Context, name: String, status: String) {
            val prefs = context.getSharedPreferences("prayer_settings_prefs", Context.MODE_PRIVATE)
            val statusKey = "alarm_status_$name"
            prefs.edit().putString(statusKey, status).apply();
        }

        fun getPrayerTimesWithSettings(context: Context, callback: (Map<String, Any>?) -> Unit) {
            val prefs = context.getSharedPreferences("prayer_settings_prefs", Context.MODE_PRIVATE)

            getPrayerTimes(context) { prayerTimes ->
                prayerTimes?.let {
                    val result = mutableMapOf<String, Any>()
                    result.putAll(it)

                    val statuses = mutableMapOf<String, String>()
                    for (prayer in it.keys) {
                        val statusKey = "alarm_status_$prayer"
                        val status = prefs.getString(statusKey, "disabled") ?: "disabled"
                        statuses[prayer] = status
                    }

                    result["__statuses__"] = statuses

                    callback(result)
                } ?: callback(null)
            }
        }

        private fun getPrayerTimes(context: Context, callback: (Map<String, Long>?) -> Unit) {
            val prefs = context.getSharedPreferences("location_prefs", Context.MODE_PRIVATE)
            val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

            if (ActivityCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(context, android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

                if (context is Activity) {
                    ActivityCompat.requestPermissions(
                        context,
                        arrayOf(
                            android.Manifest.permission.ACCESS_FINE_LOCATION,
                            android.Manifest.permission.ACCESS_COARSE_LOCATION
                        ),
                        1001 // Request code
                    )
                }

                callback(null) // Return null until permissions are granted
                return
            }

            try {
                var called = false
                val locationListener = object : LocationListener {
                    override fun onLocationChanged(location: Location) {
                        val latitude = location.latitude
                        val longitude = location.longitude

                        prefs
                            .edit()
                            .putFloat("lat", latitude.toFloat())
                            .putFloat("long", longitude.toFloat())
                            .apply()

                        val prayerTimes = getPrayerMillis(latitude, longitude)

                        // load 
                        if (!called) callback(prayerTimes)
                        called = true

                        // Remove updates after first fix
                        locationManager.removeUpdates(this)
                    }

                    override fun onProviderEnabled(provider: String) {
                        // No action needed
                    }

                    override fun onProviderDisabled(provider: String) {
                        callback(null)
                    }
                }

                if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                    locationManager.requestLocationUpdates(
                        LocationManager.NETWORK_PROVIDER,
                        0L,
                        0f,
                        locationListener
                    )
                } else {
                    promptUserToEnableLocation(context)
                    callback(null)
                }
            } catch (e: SecurityException) {
                val latitude = prefs.getFloat("lat", 500.0F).toDouble()
                val longitude = prefs.getFloat("long", 500.0F).toDouble()

                if (latitude != 500.0 && longitude != 500.0) {
                    val prayerTimes = getPrayerMillis(latitude, longitude)
                    callback(prayerTimes)
                } else {
                    callback(null)
                }
            }
        }

        fun schedulePrayerAlarms(context: Context, prayerTimesWithSettings: Map<String, Any>) {
            val currentTime = System.currentTimeMillis()
            DAILY_PRAYERS.forEach{
                name ->
                val time = prayerTimesWithSettings[name] as Long
                val status = (prayerTimesWithSettings["__statuses__"] as Map<*, *>)[name] as String
                if (time > currentTime) {
                    val prayerMap = buildMap{
                        put("name", name)
                        put("timeInMillis", time.toString())
                        put("enabled", status != "disabled")
                        if (status == "sound") {
                            put("statuses",
                                arrayOf(
                                    JSONObject("{\"runtimeType\": \"sound\"}"),
                                    JSONObject("{\"runtimeType\": \"vibrate\"}")
                                )
                            )
                        }
                        if (status == "vibrate") {
                            put("statuses", arrayOf(JSONObject("{\"runtimeType\": \"vibrate\"}")))
                        }
                    }

                    setAlarm(JSONObject(prayerMap).toString(), context, save = false, asExtra = true)
                }
            }


            // Set an alarm at the start of the next day (00:00:00)
            val calendar = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 5)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val startOfNextDayMillis = calendar.timeInMillis
            val map = mapOf(
                "name" to PRAYER_RESET,
                "timeInMillis" to startOfNextDayMillis.toString(),
                "enabled" to true,
            )
            setAlarm(JSONObject(map).toString(), context, false)
        }

        private fun promptUserToEnableLocation(context: Context) {
            val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

            if (!locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) &&
                !locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
                if (context is Activity) {
                    val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
                    context.startActivity(intent)
                } else {
                    println("Location services are disabled. Please enable them in settings.")
                }
            } else {
                println("Location services are already enabled.")
            }
        }
    }
}