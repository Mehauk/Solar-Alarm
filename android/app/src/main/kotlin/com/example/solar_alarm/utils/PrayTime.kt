// --------------------- Copyright Block ----------------------
/*

PrayTime.java: Prayer Times Calculator (ver 1.0)
Copyright (C) 2007-2010 PrayTimes.org

Java Code By: Hussain Ali Khan
Original JS Code By: Hamid Zarrabi-Zadeh

License: GNU LGPL v3.0

TERMS OF USE:
	Permission is granted to use this code, with or
	without modification, in any website or application
	provided that credit is given to the original work
	with a link back to PrayTimes.org.

This program is distributed in the hope that it will
be useful, but WITHOUT ANY WARRANTY.

PLEASE DO NOT REMOVE THIS COPYRIGHT BLOCK.

*/

package com.example.solar_alarm.utils

import java.util.Calendar
import java.util.TimeZone
import kotlin.math.abs
import kotlin.math.acos
import kotlin.math.asin
import kotlin.math.atan
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.sin
import kotlin.math.tan

class PrayTime {

    // ---------------------- Global Variables --------------------
    var calcMethod: Int = 0 // Calculation method
    var asrJuristic: Int = 0 // Juristic method for Asr
    var dhuhrMinutes: Int = 0 // Minutes after mid-day for Dhuhr
    var adjustHighLats: Int = 1 // Adjusting method for higher latitudes
    var timeFormat: Int = 0 // Time format
    var lat: Double = 0.0 // Latitude
    var lng: Double = 0.0 // Longitude
    var timeZone: Double = 0.0 // Time-zone
    var jDate: Double = 0.0 // Julian date

    // Calculation Methods
    val jafari = 0 // Ithna Ashari
    val karachi = 1 // University of Islamic Sciences, Karachi
    val isna = 2 // Islamic Society of North America (ISNA)
    val mwl = 3 // Muslim World League (MWL)
    val makkah = 4 // Umm al-Qura, Makkah
    val egypt = 5 // Egyptian General Authority of Survey
    val custom = 7 // Custom Setting
    val tehran = 6 // Institute of Geophysics, University of Tehran

    // Juristic Methods
    val shafii = 0 // Shafii (standard)
    val hanafi = 1 // Hanafi

    // Adjusting Methods for Higher Latitudes
    val none = 0 // No adjustment
    val midNight = 1 // Middle of night
    val oneSeventh = 2 // 1/7th of night
    val angleBased = 3 // Angle/60th of night

    // Time Formats
    val time24 = 0 // 24-hour format
    val time12 = 1 // 12-hour format
    val time12NS = 2 // 12-hour format with no suffix
    val floating = 3 // Floating point number

    // Time Names
    val timeNames = listOf("Fajr", "Sunrise", "Dhuhr", "Asr", "Sunset", "Maghrib", "Isha")
    val invalidTime = "-----" // The string used for invalid times

    // --------------------- Technical Settings --------------------
    var numIterations: Int = 1 // Number of iterations needed to compute times

    // ------------------- Calc Method Parameters --------------------
    val methodParams =
        mapOf(
            jafari to doubleArrayOf(16.0, 0.0, 4.0, 0.0, 14.0),
            karachi to doubleArrayOf(18.0, 1.0, 0.0, 0.0, 18.0),
            isna to doubleArrayOf(15.0, 1.0, 0.0, 0.0, 15.0),
            mwl to doubleArrayOf(18.0, 1.0, 0.0, 0.0, 17.0),
            makkah to doubleArrayOf(18.5, 1.0, 0.0, 1.0, 90.0),
            egypt to doubleArrayOf(19.5, 1.0, 0.0, 0.0, 17.5),
            tehran to doubleArrayOf(17.7, 0.0, 4.5, 0.0, 14.0),
            custom to doubleArrayOf(18.0, 1.0, 0.0, 0.0, 17.0)
        )

    var offsets = IntArray(7) { 0 }

    // ---------------------- Trigonometric Functions -----------------------
    private fun fixAngle(a: Double): Double =
        (a - 360 * floor(a / 360)).let { if (it < 0) it + 360 else it }

    private fun fixHour(a: Double): Double =
        (a - 24 * floor(a / 24)).let { if (it < 0) it + 24 else it }

    private fun radiansToDegrees(alpha: Double): Double = alpha * 180.0 / Math.PI

    private fun degreesToRadians(alpha: Double): Double = alpha * Math.PI / 180.0

    private fun dsin(d: Double): Double = sin(degreesToRadians(d))

    private fun dcos(d: Double): Double = cos(degreesToRadians(d))

    private fun dtan(d: Double): Double = tan(degreesToRadians(d))

    private fun darcsin(x: Double): Double = radiansToDegrees(asin(x))

    private fun darccos(x: Double): Double = radiansToDegrees(acos(x))

    private fun darctan(x: Double): Double = radiansToDegrees(atan(x))

    private fun darctan2(y: Double, x: Double): Double = radiansToDegrees(atan2(y, x))

    private fun darccot(x: Double): Double = radiansToDegrees(atan2(1.0, x))

    // ---------------------- Time-Zone Functions -----------------------
    private fun getTimeZone1(): Double = TimeZone.getDefault().rawOffset / 3600000.0

    private fun getBaseTimeZone(): Double = TimeZone.getDefault().rawOffset / 3600000.0

    private fun detectDaylightSaving(): Double = TimeZone.getDefault().dstSavings / 3600000.0

    // ---------------------- Julian Date Functions -----------------------
    private fun julianDate(year: Int, month: Int, day: Int): Double {
        val (y, m) = if (month <= 2) year - 1 to month + 12 else year to month
        val a = floor(y / 100.0)
        val b = 2 - a + floor(a / 4.0)
        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + day + b - 1524.5
    }

    private fun calcJD(year: Int, month: Int, day: Int): Double {
        val j1970 = 2440588.0
        val date = Calendar.getInstance().apply { set(year, month - 1, day) }.time
        val ms = date.time
        val days = floor(ms / (1000.0 * 60.0 * 60.0 * 24.0))
        return j1970 + days - 0.5
    }

    // ---------------------- Calculation Functions -----------------------
    private fun sunPosition(jd: Double): DoubleArray {
        val d = jd - 2451545
        val g = fixAngle(357.529 + 0.98560028 * d)
        val q = fixAngle(280.459 + 0.98564736 * d)
        val l = fixAngle(q + 1.915 * dsin(g) + 0.020 * dsin(2 * g))
        val e = 23.439 - 0.00000036 * d
        val dSun = darcsin(dsin(e) * dsin(l))
        val ra = fixHour(darctan2(dcos(e) * dsin(l), dcos(l)) / 15.0)
        val eqT = q / 15.0 - ra
        return doubleArrayOf(dSun, eqT)
    }

    private fun equationOfTime(jd: Double): Double = sunPosition(jd)[1]

    private fun sunDeclination(jd: Double): Double = sunPosition(jd)[0]

    private fun computeMidDay(t: Double): Double {
        val tEq = equationOfTime(jDate + t)
        return fixHour(12 - tEq)
    }

    private fun computeTime(g: Double, t: Double): Double {
        val d = sunDeclination(jDate + t)
        val z = computeMidDay(t)
        val beg = -dsin(g) - dsin(d) * dsin(lat)
        val mid = dcos(d) * dcos(lat)
        val ratio = (beg / mid).coerceIn(-1.0, 1.0)
        val v = darccos(ratio) / 15.0

        return z + if (g > 90) -v else v
    }

    private fun computeAsr(step: Double, t: Double): Double {
        val d = sunDeclination(jDate + t)
        val g = -darccot(step + dtan(abs(lat - d)))
        return computeTime(g, t)
    }

    // ---------------------- Misc Functions -----------------------
    private fun timeDiff(time1: Double, time2: Double): Double = fixHour(time2 - time1)

    // -------------------- Interface Functions --------------------
    fun getDatePrayerTimes(
        year: Int,
        month: Int,
        day: Int,
        latitude: Double,
        longitude: Double,
        tZone: Double
    ): List<Long> {
        lat = latitude
        lng = longitude
        timeZone = tZone
        jDate = julianDate(year, month, day)
        val lonDiff = longitude / (15.0 * 24.0)
        jDate -= lonDiff
        return computeDayTimes()
    }

    private fun computeDayTimes(): List<Long> {
        var times = doubleArrayOf(5.0, 6.0, 12.0, 13.0, 18.0, 18.0, 18.0)
        repeat(numIterations) { times = computeTimes(times) }
        times = adjustTimes(times)
        return times.map { (it * 60 * 60 * 1000).toLong() } // Convert directly to milliseconds
    }

    private fun computeTimes(times: DoubleArray): DoubleArray {
        val t = dayPortion(times)
        val fajr = computeTime(180 - methodParams[calcMethod]!![0], t[0])
        val sunrise = computeTime(180 - 0.833, t[1])
        val dhuhr = computeMidDay(t[2])
        val asr = computeAsr(1.0 + asrJuristic.toDouble(), t[3])
        val sunset = computeTime(0.833, t[4])
        val maghrib = computeTime(methodParams[calcMethod]!![2], t[5])
        val isha = computeTime(methodParams[calcMethod]!![4], t[6])
        return doubleArrayOf(fajr, sunrise, dhuhr, asr, sunset, maghrib, isha)
    }

    private fun adjustTimes(times: DoubleArray): DoubleArray {
        for (i in times.indices) {
            times[i] += timeZone - lng / 15
        }
        times[2] += dhuhrMinutes / 60.0
        if (methodParams[calcMethod]!![1] == 1.0) {
            times[5] = times[4] + methodParams[calcMethod]!![2] / 60.0
        }
        if (methodParams[calcMethod]!![3] == 1.0) {
            times[6] = times[5] + methodParams[calcMethod]!![4] / 60.0
        }
        if (adjustHighLats != none) {
            adjustHighLatTimes(times)
        }
        return times
    }

    private fun adjustHighLatTimes(times: DoubleArray): DoubleArray {
        val nightTime = timeDiff(times[4], times[1]) // Time between sunset and sunrise

        // Adjust Fajr
        val fajrDiff = nightPortion(methodParams[calcMethod]!![0].toDouble()) * nightTime
        if (timeDiff(times[0], times[1]) > fajrDiff) {
            times[0] = times[1] - fajrDiff
        }

        // Adjust Isha
        val ishaAngle =
            if (methodParams[calcMethod]!![3].toDouble() == 0.0)
                methodParams[calcMethod]!![4].toDouble()
            else 18.0
        val ishaDiff = nightPortion(ishaAngle) * nightTime

        if (timeDiff(times[4], times[6]) > ishaDiff) {
            times[6] = times[4] + ishaDiff
        }

        return times
    }

    private fun nightPortion(angle: Double): Double =
        when (adjustHighLats) {
            angleBased -> angle / 60.0
            midNight -> 0.5
            oneSeventh -> 0.14286
            else -> 0.0
        }

    private fun dayPortion(times: DoubleArray): DoubleArray = times.map { it / 24 }.toDoubleArray()
}
