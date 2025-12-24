package com.example.solar_alarm.utils

class Constants() {
    companion object {
        const val ONE_DAY_MILLIS = 24 * 60 * 60 * 1000L
        const val PRAYER_RESET = "__PRAYER!_!RESET__"
        const val ALARM_PREFIX = "ALARM|"
        const val DEFAULT_LATITUDE = 53.6
        const val DEFAULT_LONGITUDE = -113.3

        val DAILY_PRAYERS = setOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")
        val DAYS_OF_THE_WEEK = listOf(
            "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"
        )
    }
}
