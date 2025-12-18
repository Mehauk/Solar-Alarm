package com.mehauk.prayeralarm

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.mehauk.prayeralarm.ui.theme.Prayer_alarmTheme
import java.text.SimpleDateFormat
import java.util.Locale

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            Prayer_alarmTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    PrayerListScreen(
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@Composable
fun PrayerListScreen(
    modifier: Modifier = Modifier,
    viewModel: MainViewModel = viewModel()
) {
    val prayers by viewModel.prayers.collectAsState()

    Column(modifier = modifier.padding(16.dp)) {
        Text(
            text = "Prayer Times",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 16.dp)
        )

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(prayers) { prayer ->
                PrayerItem(
                    prayer = prayer,
                    onToggle = { viewModel.togglePrayer(prayer.name) },
                    onToggleMute = { viewModel.toggleMute(prayer.name) }
                )
            }
        }
    }
}

@Composable
fun PrayerItem(
    prayer: PrayerUiState,
    onToggle: () -> Unit,
    onToggleMute: () -> Unit
) {
    val timeFormat = SimpleDateFormat("hh:mm a", Locale.getDefault())
    
    Card(
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = prayer.name,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = timeFormat.format(prayer.time),
                    style = MaterialTheme.typography.bodyMedium
                )
            }
            
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = onToggleMute) {
                    Icon(
                        imageVector = Icons.Default.Notifications,
                        contentDescription = if (prayer.isMuted) "Unmute" else "Mute",
                        tint = if (prayer.isMuted) MaterialTheme.colorScheme.onSurface.copy(alpha = 0.3f) 
                               else MaterialTheme.colorScheme.primary
                    )
                }

                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.padding(start = 8.dp)
                ) {
                    Text(
                       text = if (prayer.isEnabled) "On" else "Off",
                       style = MaterialTheme.typography.labelSmall
                    )
                    Switch(
                        checked = prayer.isEnabled,
                        onCheckedChange = { onToggle() }
                    )
                }
            }
        }
    }
}