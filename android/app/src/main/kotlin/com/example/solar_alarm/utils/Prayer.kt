package com.example.solar_alarm.utils

import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import java.util.Calendar
import android.content.Context
import com.example.solar_alarm.utils.Alarm.Companion.setAlarm

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
            val calendar = Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC"))
            val year = calendar.get(Calendar.YEAR)
            val month = calendar.get(Calendar.MONTH) + 1 // Months are 0-based
            val day = calendar.get(Calendar.DAY_OF_MONTH)

            // Calculate prayer times
            val prayerTimes =
                prayTime.getDatePrayerTimes(
                    year,
                    month,
                    day,
                    latitudeDegrees,
                    longitudeDegrees,
                    calendar.get(Calendar.ZONE_OFFSET).toDouble() /
                            (1000 * 60 * 60)
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

        fun getPrayerAlarms(context: Context): Map<String, Long>? {
            println(1)
            val prefs = context.getSharedPreferences("location_prefs", Context.MODE_PRIVATE)

            println(2)
            val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

            var prayerTimes: Map<String, Long>? = null

            try {
                val locationListener = object : LocationListener {
                    override fun onLocationChanged(location: Location) {
                        val latitude = location.latitude
                        val longitude = location.longitude

                        prefs
                            .edit()
                            .putFloat("lat", latitude.toFloat())
                            .putFloat("long", longitude.toFloat())
                            .apply()

                        // Use the location
                        prayerTimes = getPrayerMillis(latitude, longitude)

                        println(prayerTimes)
                        // Remove updates after first fix
                        locationManager.removeUpdates(this)
                    }
                }

                locationManager.requestLocationUpdates(
                    LocationManager.GPS_PROVIDER,
                    0L,     // minTime in milliseconds
                    0f,     // minDistance in meters
                    locationListener
                )
            }
            catch(e: SecurityException) {
                val latitude = prefs.getFloat("lat", 500.0F).toDouble()
                val longitude = prefs.getFloat("long", 500.0F).toDouble()

                if (latitude != 500.0 && longitude != 500.0) {
                    prayerTimes = getPrayerMillis(latitude, longitude)
                }
            }

            return prayerTimes
        }

        fun setPrayerAlarms(context: Context): Map<String, Long>? {
            getPrayerAlarms(context)?.let {
                // listOf("Fajr", "Sunrise", "Dhuhr", "Asr", "Sunset", "Maghrib", "Isha")
                setAlarm(it["Fajr"]!!, "Fajr", context, -1)
                setAlarm(it["Dhuhr"]!!, "Dhuhr", context, -1)
                setAlarm(it["Asr"]!!, "Asr", context, -1)
                setAlarm(it["Maghrib"]!!, "Maghrib", context, -1)
                setAlarm(it["Isha"]!!, "Isha", context, -1)
                return it
            }

            return null
        }
    }
}