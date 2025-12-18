package com.mehauk.prayeralarm.prayer_utils

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.batoulapps.adhan.CalculationMethod
import com.batoulapps.adhan.Coordinates
import com.batoulapps.adhan.PrayerTimes
import com.batoulapps.adhan.data.DateComponents
import java.util.Calendar
import java.util.Date

object PrayerManager {
    // Constants for Intents
    const val EXTRA_TYPE = "type"
    const val EXTRA_PRAYER_NAME = "prayer_name"
    const val TYPE_PRAYER = "prayer"
    const val TYPE_DAILY_UPDATE = "daily_update"

    // Request Codes
    private const val RC_DAILY_UPDATE = 1000

    // Using a default calculation method (North America)
    private val calculationMethod = CalculationMethod.NORTH_AMERICA

    fun getPrayerTimes(latitude: Double, longitude: Double, date: Date = Date()): PrayerTimes {
        val coordinates = Coordinates(latitude, longitude)
        val params = calculationMethod.parameters
        val dateComponents = DateComponents.from(date)
        return PrayerTimes(coordinates, dateComponents, params)
    }

    // Returns a list of the 5 daily prayers for a given day
    fun getDailyPrayers(
            latitude: Double,
            longitude: Double,
            date: Date = Date()
    ): List<PrayerInfo> {
        val prayerTimes = getPrayerTimes(latitude, longitude, date)

        return listOf(
                PrayerInfo("Fajr", prayerTimes.fajr),
                PrayerInfo("Dhuhr", prayerTimes.dhuhr),
                PrayerInfo("Asr", prayerTimes.asr),
                PrayerInfo("Maghrib", prayerTimes.maghrib),
                PrayerInfo("Isha", prayerTimes.isha)
        )
    }

    // Main Entry point for scheduling
    fun scheduleDailyWork(context: Context) {
        // TODO: Get actual location from preferences or a location provider.
        // For now using default to ensure app works.
        val lat = 53.5462
        val lon = 113.4937

        // 1. Schedule today's remaining prayers
        val prayers = getDailyPrayers(lat, lon, Date())
        val now = System.currentTimeMillis()
        val settings = PrayerSettings(context)

        prayers.forEach { prayer ->
            if (prayer.time.time > now && settings.isPrayerEnabled(prayer.name)) {
                schedulePrayerAlarm(context, prayer)
            }
        }

        // 2. Schedule the next Daily Update (for tomorrow 1 AM)
        scheduleNextDailyUpdate(context)
    }

    private fun schedulePrayerAlarm(context: Context, prayer: PrayerInfo) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent =
                Intent(context, AlarmReceiver::class.java).apply {
                    putExtra(EXTRA_TYPE, TYPE_PRAYER)
                    putExtra(EXTRA_PRAYER_NAME, prayer.name)
                }

        // Use hashcode of prayer name as unique ID to allow updating/canceling specific prayers
        val pendingIntent =
                PendingIntent.getBroadcast(
                        context,
                        prayer.name.hashCode(),
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

        try {
            // Precise alarm
            alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    prayer.time.time,
                    pendingIntent
            )
            println("Scheduled ${prayer.name} at ${prayer.time}")
        } catch (e: SecurityException) {
            // Handle permission not granted (should be handled in UI)
            e.printStackTrace()
        }
    }

    private fun scheduleNextDailyUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent =
                Intent(context, AlarmReceiver::class.java).apply {
                    putExtra(EXTRA_TYPE, TYPE_DAILY_UPDATE)
                }

        val pendingIntent =
                PendingIntent.getBroadcast(
                        context,
                        RC_DAILY_UPDATE,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

        // Calculate tomorrow 1:00 AM
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, 1)
        calendar.set(Calendar.HOUR_OF_DAY, 1)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)

        try {
            alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
            )
            println("Scheduled Daily Update at ${calendar.time}")
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }

    fun cancelAlarm(context: Context, prayerName: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent =
                Intent(context, AlarmReceiver::class.java).apply {
                    putExtra(EXTRA_TYPE, TYPE_PRAYER)
                    putExtra(EXTRA_PRAYER_NAME, prayerName)
                }
        val pendingIntent =
                PendingIntent.getBroadcast(
                        context,
                        prayerName.hashCode(),
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or
                                PendingIntent.FLAG_IMMUTABLE or
                                PendingIntent.FLAG_NO_CREATE
                )

        if (pendingIntent != null) {
            alarmManager.cancel(pendingIntent)
            pendingIntent.cancel()
            println("Cancelled alarm for $prayerName")
        }
    }
}

data class PrayerInfo(val name: String, val time: Date)
