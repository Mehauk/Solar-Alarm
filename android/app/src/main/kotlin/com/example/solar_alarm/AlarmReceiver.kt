package com.example.solar_alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import com.example.solar_alarm.utils.Alarm
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET
import com.example.solar_alarm.utils.Prayer
import org.json.JSONObject

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        println("AlarmReceiver " + SystemClock.currentThreadTimeMillis().toString() + " in com.example.solar_alarm.AlarmReceiver onReceive()")
        val alarmName = intent.getStringExtra("alarmName")

        if (alarmName == PRAYER_RESET) {
            Prayer.setPrayerAlarms(context)
        } else {
            Alarm.getAlarm(alarmName!!, context)?.let {
                val alarm = JSONObject(it)
                val alarmIntent = Intent(context, AlarmActivity::class.java)
                alarmIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                alarmIntent.putExtra("alarmName", alarmName)

                context.startActivity(alarmIntent)

                val repeatInterval = alarm.optString("repeatInterval").toLongOrNull()

                if (repeatInterval != null && repeatInterval > 1000L) {
                    alarm.put(
                        "timeInMillis",
                        alarm.getString("timeInMillis").toLong() + repeatInterval
                    )
                    println("alarm $alarmName set to reset $repeatInterval")
                    Alarm.setAlarm(alarm.toString(), context)
                } else {
                    Alarm.disableAlarm(alarmName, context)
                }
            }

        }

    }
}