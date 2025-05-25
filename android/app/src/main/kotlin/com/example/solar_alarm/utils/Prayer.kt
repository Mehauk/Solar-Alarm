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
        private const val MINUTES_AT_HALF_DAY = 720
        private const val DEGREES_PER_MINUTE = 0.25
        private const val DAYS_IN_A_YEAR = 365

        fun getPrayerMillis(
                latitude: Double,
                longitude: Double,
                currentTimeMillis: Long
        ): Map<String, Long> {
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
            val zenith = getZenith(longitude, dayOfYear)
            val declinationAngle = getSolarDeclination(dayOfYear)
            val timeDiffAtZero =
                    getMinutesFromZenith(0.0, latitude, declinationAngle, zenith).toLong() *
                            60 *
                            1000

            val dhur = getDhur(startOfDayMillis, zenith)

            return mapOf(
                    //                "Fajr" to getDhur(lat, long, startOfDayMillis),
                    "Sunrise" to dhur - timeDiffAtZero,
                    "Dhur" to dhur,
                    "Dhur2" to
                            getDhur(
                                    startOfDayMillis,
                                    getMinutesFromZenith(PI / 2, latitude, declinationAngle, zenith)
                            ),
                    //                "Asr" to getDhur(lat, long, startOfDayMillis),
                    //                "Maghrib" to getDhur(lat, long, startOfDayMillis),
                    "Sunset" to dhur + timeDiffAtZero,
                    //                "Isha" to getDhur(lat, long, startOfDayMillis),

                    )
        }

        private fun getDhur(startOfDayMillis: Long, zenith: Double): Long {
            val solarNoonMillis = (zenith * 60 * 1000).toLong()

            return startOfDayMillis + solarNoonMillis
        }

        private fun getZenith(longitude: Double, dayOfYear: Int): Double {

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
            val solarNoonMinutes = MINUTES_AT_HALF_DAY - (longitude / DEGREES_PER_MINUTE) - eqTime
            return solarNoonMinutes
        }

        private fun getSolarDeclination(dayOfYear: Int): Double {
            return -(23.45 * PI / 180) * cos((2 * PI / DAYS_IN_A_YEAR) * (dayOfYear + 10))
        }

        private fun getLocalMinuteAngle(minutesOfTheDay: Long, zenith: Long): Double {
            return DEGREES_PER_MINUTE * (minutesOfTheDay - zenith)
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

        private fun getMinutesFromZenith(
                minuteAngle: Double,
                latitude: Double,
                declinationAngle: Double,
                zenith: Double,
        ): Double {

            return 4 *
                    acos(
                            (sin(minuteAngle) - sin(declinationAngle) * sin(latitude)) /
                                    (cos(declinationAngle) * cos(latitude))
                    ) + zenith
        }
    }
}
