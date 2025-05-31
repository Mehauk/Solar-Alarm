package com.example.solar_alarm.utils

import android.app.Activity
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import java.util.Calendar
import android.content.Context
import android.content.Intent
import com.example.solar_alarm.utils.Alarm.Companion.setAlarm
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import android.provider.Settings

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
            val prefs = context.getSharedPreferences("location_prefs", Context.MODE_PRIVATE)
            val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

            var prayerTimes: Map<String, Long>? = null

            try {
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

                    return null // Return null until permissions are granted
                }

                val locationListener = object : LocationListener {
                    override fun onLocationChanged(location: Location) {
                        val latitude = location.latitude
                        val longitude = location.longitude

                        prefs
                            .edit()
                            .putFloat("lat", latitude.toFloat())
                            .putFloat("long", longitude.toFloat())
                            .apply()

                        prayerTimes = getPrayerMillis(latitude, longitude)

                        // Remove updates after first fix
                        locationManager.removeUpdates(this)
                    }

                    override fun onProviderEnabled(provider: String) {
                        // No action needed
                    }

                    override fun onProviderDisabled(provider: String) {
                        throw IllegalStateException("Location provider disabled: $provider")
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
                    return null
                }
            } catch (e: SecurityException) {
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

        fun promptUserToEnableLocation(context: Context) {
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