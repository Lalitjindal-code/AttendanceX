package com.lalitjindal.attendify.widget

import android.content.Context
import androidx.glance.appwidget.updateAll
import androidx.work.*
import org.json.JSONObject
import java.util.Calendar
import java.util.concurrent.TimeUnit

/**
 * WorkManager [CoroutineWorker] that re-renders the Attendify widget.
 *
 * One [WidgetUpdateWorker] job is scheduled for each class period's start
 * time, plus one at midnight to reset the next day's schedule.
 *
 * Scheduling is triggered from Flutter via [WidgetScheduler.scheduleAll].
 */
class WidgetUpdateWorker(
    private val appContext: Context,
    params: WorkerParameters,
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        // Re-render the Glance widget with whatever is currently in SharedPreferences
        AttendifyWidget().updateAll(appContext)

        // Re-schedule for the next period (handles cases where the device woke from sleep)
        WidgetScheduler.scheduleAll(appContext)

        return Result.success()
    }

    companion object {
        const val TAG = "AttendifyWidgetUpdate"
    }
}

/**
 * Schedules one [WidgetUpdateWorker] job per class period start time for today,
 * plus a midnight reset job for tomorrow.
 *
 * Existing jobs with [WidgetUpdateWorker.TAG] are cancelled first to avoid duplicates.
 */
object WidgetScheduler {

    fun scheduleAll(context: Context) {
        val workManager = WorkManager.getInstance(context)

        // Cancel existing period jobs
        workManager.cancelAllWorkByTag(WidgetUpdateWorker.TAG)

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

        // Schedule a job for each upcoming start time today
        startTimes.filter { it > nowMinutes }.forEachIndexed { index, minutes ->
            val delayMs = (minutes - nowMinutes) * 60_000L
            enqueueDelayed(workManager, delayMs, "period_$index")
        }

        // Also schedule a midnight reset (23:59 → next day's data will come from Flutter on resume)
        val midnightMinutes = 23 * 60 + 59
        if (nowMinutes < midnightMinutes) {
            val delayMs = (midnightMinutes - nowMinutes) * 60_000L
            enqueueDelayed(workManager, delayMs, "midnight_reset")
        }
    }

    private fun enqueueDelayed(workManager: WorkManager, delayMs: Long, name: String) {
        val request = OneTimeWorkRequestBuilder<WidgetUpdateWorker>()
            .setInitialDelay(delayMs, TimeUnit.MILLISECONDS)
            .addTag(WidgetUpdateWorker.TAG)
            .setConstraints(Constraints.Builder().build())
            .build()

        workManager.enqueueUniqueWork(
            "attendify_widget_$name",
            ExistingWorkPolicy.REPLACE,
            request,
        )
    }
}
