package com.lalitjindal.attendify.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.glance.appwidget.updateAll
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONObject
import java.util.Calendar

/**
 * Receiver that re-renders the Attendify widget when triggered by AlarmManager.
 */
class WidgetUpdateAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        CoroutineScope(Dispatchers.Main).launch {
            // Re-render the Glance widget with whatever is currently in SharedPreferences
            AttendifyWidget().updateAll(context)
            // Re-schedule for the next period
            WidgetScheduler.scheduleAll(context)
        }
    }
}

/**
 * Schedules exact alarms using AlarmManager to update the widget right when a class starts.
 */
object WidgetScheduler {

    fun scheduleAll(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        // Read today's schedule from SharedPreferences
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val raw = prefs.getString("attendify_widget_data", null) ?: return

        val cal = Calendar.getInstance()
        val todayDart = if (cal.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) 7 else cal.get(Calendar.DAY_OF_WEEK) - 1
        
        val startTimes = mutableListOf<Int>() // minutes since midnight
        try {
            val obj = JSONObject(raw)
            val arr = obj.getJSONArray("cards")
            for (i in 0 until arr.length()) {
                val cardObj = arr.getJSONObject(i)
                if (cardObj.getInt("dayOfWeek") == todayDart) {
                    val timeStr = cardObj.getString("startTime")
                    val parts = timeStr.split(":")
                    val minutes = parts[0].toIntOrNull()?.times(60)?.plus(parts[1].toIntOrNull() ?: 0)
                    if (minutes != null) startTimes.add(minutes)
                }
            }
        } catch (_: Exception) {}
        
        val nowMinutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)

        // Find the next closest start time today
        val nextStartTime = startTimes.filter { it > nowMinutes }.minOrNull()
        
        // Always set a midnight reset alarm (to load tomorrow's data)
        val midnightMinutes = 23 * 60 + 59
        
        val targetMinutes = nextStartTime ?: midnightMinutes
        
        if (targetMinutes > nowMinutes) {
            val targetCal = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, targetMinutes / 60)
                set(Calendar.MINUTE, targetMinutes % 60)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            
            val intent = Intent(context, WidgetUpdateAlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                1001, // Single ID because we only need ONE next alarm (either class or midnight)
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    if (alarmManager.canScheduleExactAlarms()) {
                        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, targetCal.timeInMillis, pendingIntent)
                    } else {
                        alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, targetCal.timeInMillis, pendingIntent)
                    }
                } else {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, targetCal.timeInMillis, pendingIntent)
                }
            } catch (e: Exception) {
                // Fallback
                alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, targetCal.timeInMillis, pendingIntent)
            }
        }
    }
}
