package com.example.solar_alarm.utils

class Constants() {
    companion object {
        const val ONE_DAY_MILLIS = 24 * 60 * 60 * 1000L
        const val PRAYER_RESET = "__PRAYER!_!RESET__"
        const val ALARM_PREFIX = "ALARM|"
        val DAILY_PRAYERS = setOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")
    }
}
