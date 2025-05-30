package com.example.solar_alarm.utils

import java.util.Calendar

class Prayer {
        companion object {
                fun getPrayerMillis(
                        latitudeDegrees: Double,
                        longitudeDegrees: Double,
                        currentTimeMillis: Long
                ): Map<String, Long> {
                        // Create an instance of the PrayTime class
                        val prayTime = PrayTime()

                        // Configure the PrayTime instance
                        prayTime.timeFormat = prayTime.time24
                        prayTime.calcMethod = prayTime.mwl // Example: Muslim World League
                        prayTime.asrJuristic = prayTime.shafii
                        prayTime.adjustHighLats = prayTime.angleBased

                        // Get the current date
                        val calendar =
                                Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC")).apply {
                                        timeInMillis = currentTimeMillis
                                }
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
        }
}
