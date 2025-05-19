package com.example.solar_alarm

import android.app.Activity
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import com.example.solar_alarm.utils.Alarm.Companion.setAlarm

class AlarmActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            )
        }
        // Hide status bar for fullscreen (API 30+)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            window.insetsController?.hide(android.view.WindowInsets.Type.statusBars())
        } else {
            @Suppress("DEPRECATION")
            window.setFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN
            )
        }
        setContentView(R.layout.activity_alarm)

        val alarmName = intent.getStringExtra("alarmName") ?: "ALARM!"
        findViewById<TextView>(R.id.alarmTitle).text = alarmName

        findViewById<Button>(R.id.dismissButton).setOnClickListener {
            Toast.makeText(this, "Alarm dismissed", Toast.LENGTH_SHORT).show()
            finish()
        }
        findViewById<Button>(R.id.snoozeButton).setOnClickListener {
            Toast.makeText(this, "Snoozed for 5 minutes", Toast.LENGTH_SHORT).show()
            val timeInMillis = System.currentTimeMillis() + (1_000 * 60 * 5)
            val context = applicationContext
            setAlarm(timeInMillis, alarmName, context)
            finish()
        }
    }
}
