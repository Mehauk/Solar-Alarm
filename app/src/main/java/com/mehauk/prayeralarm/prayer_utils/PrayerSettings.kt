package com.mehauk.prayeralarm.prayer_utils

import android.content.Context

class PrayerSettings(context: Context) {
    private val prefs = context.getSharedPreferences("prayer_settings", Context.MODE_PRIVATE)

    fun isPrayerEnabled(prayerName: String): Boolean {
        // Default all enabled
        return prefs.getBoolean("enabled_$prayerName", true)
    }

    fun setPrayerEnabled(prayerName: String, enabled: Boolean) {
        prefs.edit().putBoolean("enabled_$prayerName", enabled).apply()
    }

    fun isPrayerMuted(prayerName: String): Boolean {
        return prefs.getBoolean("muted_$prayerName", false)
    }

    fun setPrayerMuted(prayerName: String, muted: Boolean) {
        prefs.edit().putBoolean("muted_$prayerName", muted).apply()
    }
}
