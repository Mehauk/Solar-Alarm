package com.example.solar_alarm.utils

import java.util.Calendar
import java.util.TimeZone
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

class Prayer {
    companion object {
        private const val MINUTES_AT_HALF_DAY = 720
        private const val DEGREES_PER_MINUTE = 4.0

        fun getPrayerMillis(lat: Double, long: Double, currentTimeMillis: Long): Map<String, Long> {
            val startOfDayMillis = Calendar.getInstance(TimeZone.getTimeZone("UTC")).apply {
                timeInMillis = currentTimeMillis
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }.timeInMillis

            return mapOf(
//                "Fajr" to getDhur(lat, long, startOfDayMillis),
                "Dhur" to getDhur(lat, long, startOfDayMillis),
//                "Asr" to getDhur(lat, long, startOfDayMillis),
//                "Maghrib" to getDhur(lat, long, startOfDayMillis),
//                "Isha" to getDhur(lat, long, startOfDayMillis),

            )
        }

        private fun getDhur(latitude: Double, longitude: Double, startOfDayMillis: Long): Long {
            // Step 1: Get the day of the year in UTC
            val date = Calendar.getInstance(TimeZone.getTimeZone("UTC")).apply {
                timeInMillis = startOfDayMillis
            }
            val dayOfYear = date.get(Calendar.DAY_OF_YEAR)

            // Step 2: Calculate the fractional year in radians
            val gamma = 2 * PI / 365 * (dayOfYear - 1)

            // Step 3: Calculate the Equation of Time (EoT)
            val scalingFactor = 229.18 / (60 * 24) // ~0.15915, this converts to minutes
            val eqTime = 60 * 24 * scalingFactor * (
                    0.000075 +
                            0.001868 * cos(gamma) -
                            0.032077 * sin(gamma) -
                            0.014615 * cos(2 * gamma) -
                            0.040849 * sin(2 * gamma)
                    )

            // Step 4: Solar Noon in UTC minutes from midnight
            val solarNoonMinutes = MINUTES_AT_HALF_DAY - (DEGREES_PER_MINUTE * longitude) - eqTime

            // Step 5: Convert minutes to milliseconds since midnight
            val solarNoonMillis = (solarNoonMinutes * 60 * 1000).toLong()

            return startOfDayMillis + solarNoonMillis
        }
    }
}
