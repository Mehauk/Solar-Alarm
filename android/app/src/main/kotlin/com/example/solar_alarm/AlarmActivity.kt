package com.example.solar_alarm

import android.app.Activity
import android.graphics.drawable.GradientDrawable
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Vibrator
import android.view.WindowManager
import android.widget.Button
import android.widget.RelativeLayout
import android.widget.TextView
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.example.solar_alarm.utils.Alarm
import com.example.solar_alarm.utils.Alarm.Companion.setAlarm
import com.example.solar_alarm.utils.Constants.Companion.PRAYER_RESET
import org.json.JSONObject

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
        val alarmTime = intent.getLongExtra("alarmTime", 0);
        val alarmSoundStatus = intent.getBooleanExtra("alarmSoundStatus", false);
        val alarmVibrateStatus = intent.getBooleanExtra("alarmVibrateStatus", false);

        findViewById<TextView>(R.id.alarmTitle).text = alarmName

        // Retrieve the alarm time and display it
        val formattedTime = java.text.SimpleDateFormat("hh:mm a", java.util.Locale.getDefault()).format(java.util.Date(alarmTime))
        findViewById<TextView>(R.id.timeText).text = formattedTime

        // Vibrate and play sound if not silent
        val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager


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

            if (alarmSoundStatus) {
                handler.post(playSoundRunnable)
            }


            val vibrator = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                getSystemService(Vibrator::class.java)
            } else {
                @Suppress("DEPRECATION")
                getSystemService(VIBRATOR_SERVICE) as Vibrator
            }
            // Vibrate
            val vibrationPattern = longArrayOf(0, 500, 1000) // Delay, Vibrate, Sleep
            if (alarmVibrateStatus) {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    val effect = android.os.VibrationEffect.createWaveform(vibrationPattern, 0) // 0 to repeat from start
                    vibrator.vibrate(effect)
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(vibrationPattern, 0) // Pass -1 for no repeat, or 0 to repeat from start
                }
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
            val map = mapOf(
                "name" to alarmName,
                "timeInMillis" to timeInMillis.toString(),
                "enabled" to true,
            )
            setAlarm(JSONObject(map).toString(), context, save = false, asExtra =  false, unique = true)
            finish()
        }
        changeAlarmUIBasedOnSolarTimes()
    }

    private fun changeAlarmUIBasedOnSolarTimes() {
        // Set background gradient based on the time of day
        val currentHour = java.util.Calendar.getInstance().get(java.util.Calendar.HOUR_OF_DAY)

        // Set text and button colors based on the time of day for better contrast
        val textColor: Int
        val buttonTextColor: Int
//        val buttonBackgroundColor: Int
        val backgroundDrawable: GradientDrawable
                val contrastingBackgroundColor: Int
        val contrastingStrokeColor: Int
        
        when (currentHour) {
            in 4..8 -> {
                contrastingBackgroundColor = 0xFF1A1A2E.toInt() // Contrast for dawn gradient
                contrastingStrokeColor = 0xFFB5FFFC.toInt()
                textColor = 0xFF000000.toInt() // Black for dawn
                buttonTextColor = 0xFF000000.toInt()
//                buttonBackgroundColor = 0xFFFFFFFF.toInt() // White
                backgroundDrawable = GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, intArrayOf(0xFFFFDEE9.toInt(), 0xFFB5FFFC.toInt()))
            }
            in 9..11 -> {
                contrastingBackgroundColor = 0xFF16213E.toInt() // Contrast for morning gradient
                contrastingStrokeColor = 0xFFFFD700.toInt()
                textColor = 0xFF000000.toInt() // Black for morning
                buttonTextColor = 0xFF000000.toInt()
//                buttonBackgroundColor = 0xFFFFFFFF.toInt() // White
                backgroundDrawable = GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, intArrayOf(0xFFFFFACD.toInt(), 0xFFFFD700.toInt()))
            }
            in 12..17 -> {
                contrastingBackgroundColor = 0xFF1A1A2E.toInt() // Contrast for afternoon gradient
                contrastingStrokeColor = 0xFF00BFFF.toInt()
                textColor = 0xFFFFFFFF.toInt() // White for afternoon
                buttonTextColor = 0xFFFFFFFF.toInt()
//                buttonBackgroundColor = 0xFF000000.toInt() // Black
                backgroundDrawable =GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, intArrayOf(0xFF87CEEB.toInt(), 0xFF00BFFF.toInt()))
            }
            in 18..20 -> {
                                contrastingBackgroundColor = 0xFF1A1A2E.toInt() // Contrast for evening gradient
                contrastingStrokeColor = 0xFFFEB47B.toInt()
                textColor = 0xFFFFFFFF.toInt() // White for evening
                buttonTextColor = 0xFFFFFFFF.toInt()
//                buttonBackgroundColor = 0xFF000000.toInt() // Black
                backgroundDrawable = GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, intArrayOf(0xFFFF7E5F.toInt(), 0xFFFEB47B.toInt()))
            }
            else -> {
                                contrastingBackgroundColor = 0xFFFFFACD.toInt() // Contrast for night gradient
                contrastingStrokeColor = 0xFF16213E.toInt()
                textColor = 0xFFFFFFFF.toInt() // White for night
                buttonTextColor = 0xFFFFFFFF.toInt()
//                buttonBackgroundColor = 0xFF000000.toInt() // Black
                backgroundDrawable = GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, intArrayOf(0xFF1A1A2E.toInt(), 0xFF16213E.toInt()))
            }
        }
        findViewById<RelativeLayout>(R.id.container).background = backgroundDrawable

        findViewById<TextView>(R.id.timeText).setTextColor(textColor)
        findViewById<TextView>(R.id.alarmTitle).setTextColor(textColor)

        // Update button colors dynamically while preserving shape data
        val dismissButton = findViewById<Button>(R.id.dismissButton)
        val snoozeButton = findViewById<Button>(R.id.snoozeButton)

        // Update dismiss button to have contrasting background and stroke
        val dismissButtonBackground = ContextCompat.getDrawable(this, R.drawable.dismiss_button_background) as GradientDrawable


        dismissButtonBackground.setColor(contrastingBackgroundColor)
        dismissButtonBackground.setStroke(4, contrastingBackgroundColor) // Set stroke color and width
        dismissButton.background = dismissButtonBackground
        dismissButton.setTextColor(contrastingStrokeColor)

        val snoozeButtonBackground = ContextCompat.getDrawable(this, R.drawable.snooze_button_background) as GradientDrawable
        snoozeButtonBackground.setStroke(2, buttonTextColor) // Update stroke color
        snoozeButton.background = snoozeButtonBackground
        snoozeButton.setTextColor(buttonTextColor)
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
