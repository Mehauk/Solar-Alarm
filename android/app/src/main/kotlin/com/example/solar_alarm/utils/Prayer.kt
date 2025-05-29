package com.example.solar_alarm.utils

import java.util.Calendar
import java.util.TimeZone
import kotlin.math.PI
import kotlin.math.acos
import kotlin.math.asin
import kotlin.math.cos
import kotlin.math.sin

class Prayer {
        companion object {
                private const val DEG_TO_RAD = PI / 180
                private const val MILLIS_AT_HALF_DAY = 720 * 60_000
                private const val RAD_PER_MILLISECOND = 0.25 * DEG_TO_RAD / 60_000
                private const val DAYS_IN_A_YEAR = 365
                private const val MAX_SOLAR_DECLINATION = 23.45 * DEG_TO_RAD

                fun getPrayerMillis(
                        latitudeDegrees: Double,
                        longitudeDegrees: Double,
                        currentTimeMillis: Long
                ): Map<String, Long> {
                        val latitude = latitudeDegrees * DEG_TO_RAD
                        val longitude = longitudeDegrees * DEG_TO_RAD
                        val startOfDayMillis =
                                Calendar.getInstance(TimeZone.getTimeZone("UTC"))
                                        .apply {
                                                timeInMillis = currentTimeMillis
                                                set(Calendar.HOUR_OF_DAY, 0)
                                                set(Calendar.MINUTE, 0)
                                                set(Calendar.SECOND, 0)
                                                set(Calendar.MILLISECOND, 0)
                                        }
                                        .timeInMillis
                        val date =
                                Calendar.getInstance(TimeZone.getTimeZone("UTC")).apply {
                                        timeInMillis = startOfDayMillis
                                }
                        val dayOfYear = date.get(Calendar.DAY_OF_YEAR)
                        val noon = getNoon(longitude, dayOfYear)
                        val declinationAngle = getSolarDeclination(dayOfYear)
                        val timeDiffAtZero =
                                getTimeOffsetFromNoon(latitude, declinationAngle, 0.0).toLong() *
                                        60 *
                                        1000
                        android.util.Log.d(
                                "PrayerCalc",
                                "latitude - MAX_SOLAR_DECLINATION - PI/2: ${Math.max(
                                                        -18 * DEG_TO_RAD,
                                                        latitude - MAX_SOLAR_DECLINATION - PI / 2
                                                )/DEG_TO_RAD}"
                        )
                        val timeDiffAt18Below =
                                getTimeOffsetFromNoon(
                                                latitude,
                                                declinationAngle,
                                                Math.max(
                                                        -18 * DEG_TO_RAD,
                                                        latitude - MAX_SOLAR_DECLINATION - PI / 2
                                                )
                                        )
                                        .toLong() * 60 * 1000

                        val dhur = getDhur(startOfDayMillis, noon)

                        return mapOf(
                                "Fajr" to dhur - timeDiffAt18Below,
                                "Sunrise" to dhur - timeDiffAtZero,
                                "Dhur" to dhur,
                                //                "Asr" to getDhur(lat, long, startOfDayMillis),
                                //                "Maghrib" to getDhur(lat, long, startOfDayMillis),
                                "Sunset" to dhur + timeDiffAtZero,
                                "Isha" to dhur + timeDiffAt18Below,
                        )
                }

                private fun getDhur(startOfDayMillis: Long, noon: Long): Long {
                        val solarNoonMillis = noon

                        return startOfDayMillis + solarNoonMillis
                }

                private fun getNoon(longitude: Double, dayOfYear: Int): Long {

                        // Step 1: Calculate the fractional year in radians
                        val gamma = 2 * PI / DAYS_IN_A_YEAR * (dayOfYear - 1)

                        // Step 2: Calculate the Equation of Time (EoT)
                        val scalingFactor = 229.18 / (60 * 24) // ~0.15915, this converts to minutes
                        val eqTime =
                                60 *
                                        24 *
                                        scalingFactor *
                                        (0.000075 + 0.001868 * cos(gamma) -
                                                0.032077 * sin(gamma) -
                                                0.014615 * cos(2 * gamma) -
                                                0.040849 * sin(2 * gamma))

                        // Step 3: Solar Noon in UTC minutes from midnight
                        val solarNoonMinutes =
                                MILLIS_AT_HALF_DAY - (longitude / RAD_PER_MILLISECOND) - eqTime
                        return solarNoonMinutes.toLong()
                }

                private fun getSolarDeclination(dayOfYear: Int): Double {
                        return -(MAX_SOLAR_DECLINATION) *
                                cos((2 * PI / DAYS_IN_A_YEAR) * (dayOfYear + 10))
                }

                private fun getSolarElevation(
                        declination: Double,
                        latitude: Double,
                        minuteAngle: Double
                ): Double {
                        return asin(
                                sin(declination) * sin(latitude) +
                                        cos(declination) * cos(latitude) * cos(minuteAngle)
                        )
                }

                private fun getTimeOffsetFromNoon(
                        latitude: Double,
                        declination: Double,
                        solarElevation: Double
                ): Long {
                        // Calculate the hour angle (H) for the given solar elevation
                        val cosH =
                                (sin(solarElevation) - sin(latitude) * sin(declination)) /
                                        (cos(latitude) * cos(declination))
                        println("cosH: $cosH")
                        val hourAngle = acos(cosH) // in radians

                        // Convert hour angle to time (in minutes)
                        val timeOffsetMillis = hourAngle / RAD_PER_MILLISECOND // radians -> minutes

                        return timeOffsetMillis.toLong()
                }
        }
}
