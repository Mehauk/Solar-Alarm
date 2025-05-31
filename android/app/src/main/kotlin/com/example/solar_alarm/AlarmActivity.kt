package com.example.solar_alarm

import android.app.Activity
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Vibrator
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import com.example.solar_alarm.utils.Alarm.Companion.setAlarm

class AlarmActivity : Activity() {
    private lateinit var mediaPlayer: MediaPlayer
    private lateinit var handler: Handler

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

        // Retrieve the alarm time and display it
        val alarmTime = intent.getLongExtra("alarmTime", 0)
        val formattedTime = java.text.SimpleDateFormat("hh:mm a", java.util.Locale.getDefault()).format(java.util.Date(alarmTime))
        findViewById<TextView>(R.id.timeText).text = formattedTime

        // Vibrate and play sound if not silent
        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
        val vibrator = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            getSystemService(Vibrator::class.java)
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as Vibrator
        }

        if (audioManager.ringerMode != AudioManager.RINGER_MODE_SILENT) {
            // Play alarm sound repeatedly every 3 seconds
            mediaPlayer = MediaPlayer.create(this, R.raw.alarm_sound) // Replace with your alarm sound resource
            handler = Handler(Looper.getMainLooper())

            val playSoundRunnable = object : Runnable {
                override fun run() {
                    if (!mediaPlayer.isPlaying) {
                        mediaPlayer.start()
                    }
                    handler.postDelayed(this, 3000) // Repeat every 3 seconds
                }
            }

            mediaPlayer.setOnCompletionListener {
                mediaPlayer.seekTo(0) // Reset to the beginning
            }

            handler.post(playSoundRunnable)

            // Vibrate
            val vibrationPattern = longArrayOf(0, 500, 1000) // Delay, Vibrate, Sleep
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                val effect = android.os.VibrationEffect.createWaveform(vibrationPattern, 0) // 0 to repeat from start
                vibrator.vibrate(effect)
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(vibrationPattern, 0) // Pass -1 for no repeat, or 0 to repeat from start
            }

            // Stop vibration and sound when activity is destroyed
            findViewById<Button>(R.id.dismissButton).setOnClickListener {
                handler.removeCallbacks(playSoundRunnable)
                Toast.makeText(this, "Alarm dismissed", Toast.LENGTH_SHORT).show()
                finish()
            }
        }
        findViewById<Button>(R.id.snoozeButton).setOnClickListener {
            Toast.makeText(this, "Snoozed for 5 minutes", Toast.LENGTH_SHORT).show()
            val timeInMillis = System.currentTimeMillis() + (1_000 * 5)
            val context = applicationContext
            val snoozeName = alarmName.split("__SNOOZED")[0] + "__SNOOZED"
            setAlarm(timeInMillis, snoozeName, context, null)
            finish()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Stop and release MediaPlayer
        if (::mediaPlayer.isInitialized) {
            try {
                if (mediaPlayer.isPlaying) {
                    mediaPlayer.stop()
                }
                mediaPlayer.release()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        // Stop vibration
        val vibrator = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            getSystemService(Vibrator::class.java)
        } else {
            @Suppress("DEPRECATION")
            getSystemService(VIBRATOR_SERVICE) as Vibrator
        }
        vibrator.cancel()

        // Remove any pending callbacks
        if (::handler.isInitialized) {
            handler.removeCallbacksAndMessages(null)
        }
    }
}
