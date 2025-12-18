package com.mehauk.prayeralarm

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import com.mehauk.prayeralarm.prayer_utils.PrayerManager
import com.mehauk.prayeralarm.prayer_utils.PrayerSettings
import java.util.Date
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

data class PrayerUiState(
        val name: String,
        val time: Date,
        val isEnabled: Boolean = true,
        val isMuted: Boolean = false
)

class MainViewModel(application: Application) : AndroidViewModel(application) {
    private val settings = PrayerSettings(application)
    private val _prayers = MutableStateFlow<List<PrayerUiState>>(emptyList())
    val prayers: StateFlow<List<PrayerUiState>> = _prayers.asStateFlow()

    init {
        loadPrayers()
        // Start a ticker to update next prayer countdown if needed, or just refresh occasionally
        // For now just load once. In a real app we might want to refresh at midnight.
    }

    private fun loadPrayers() {
        // Hardcoded location matching PrayerManager default
        val lat = 37.7749
        val lon = -122.4194

        val dailyPrayers = PrayerManager.getDailyPrayers(lat, lon, Date())
        _prayers.value =
                dailyPrayers.map {
                    PrayerUiState(
                            name = it.name,
                            time = it.time,
                            isEnabled = settings.isPrayerEnabled(it.name),
                            isMuted = settings.isPrayerMuted(it.name)
                    )
                }
    }

    fun togglePrayer(prayerName: String) {
        val currentState = _prayers.value
        val prayerIndex = currentState.indexOfFirst { it.name == prayerName }
        if (prayerIndex != -1) {
            val prayer = currentState[prayerIndex]
            val newState = !prayer.isEnabled

            // Save preference
            settings.setPrayerEnabled(prayerName, newState)

            // Update UI
            _prayers.update { list ->
                list.toMutableList().apply { this[prayerIndex] = prayer.copy(isEnabled = newState) }
            }

            // Reschedule alarms to reflect change immediately
            // This is a heavy operation (cancels everything effectively?)
            // Our current scheduleDailyWork blindly schedules.
            // Ideally we cancel the specific alarm if disabled.
            // For simplicity: simple rescheduling.
            // Note: scheduleDailyWork basically ADDS alarms.
            // To properly support toggling OFF, we need to CANCEL the PendingIntent.

            if (newState) {
                PrayerManager.scheduleDailyWork(getApplication())
            } else {
                // Cancel
                cancelPrayerAlarm(prayerName)
            }
        }
    }

    fun toggleMute(prayerName: String) {
        val currentState = _prayers.value
        val prayerIndex = currentState.indexOfFirst { it.name == prayerName }
        if (prayerIndex != -1) {
            val prayer = currentState[prayerIndex]
            val newState = !prayer.isMuted

            settings.setPrayerMuted(prayerName, newState)

            _prayers.update { list ->
                list.toMutableList().apply { this[prayerIndex] = prayer.copy(isMuted = newState) }
            }
        }
    }

    private fun cancelPrayerAlarm(prayerName: String) {
        // Logic to cancel the alarm using the same PendingIntent structure
        // We can expose a cancel helper in PrayerManager to keep logic encapsulated
        // For now, I'll access it directly or add a helper method to PrayerManager.
        PrayerManager.cancelAlarm(getApplication(), prayerName)
    }
}
