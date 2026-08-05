package com.lalitjindal.attendify.widget

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import org.json.JSONObject
import java.util.Calendar
import java.text.SimpleDateFormat
import java.util.Locale

// ─── Data model ───────────────────────────────────────────────────────────────

data class ScheduleCard(
    val scheduleId: Int,
    val dayOfWeek: Int,
    val subjectName: String,
    val subjectColor: Int,
    val startTime: String,
    val endTime: String,
    val room: String?,
    val type: String,
    val attendanceStatus: String,
    val attendancePercent: Double,
    val goalPercent: Double,
)

data class WidgetData(
    val cards: List<ScheduleCard>,
    val overallAttendance: String,
)

// ─── Helpers ──────────────────────────────────────────────────────────────────

private fun parseWidgetData(json: String): WidgetData {
    return try {
        val obj = JSONObject(json)
        val arr = obj.getJSONArray("cards")
        val cards = (0 until arr.length()).map { i ->
            val c = arr.getJSONObject(i)
            ScheduleCard(
                scheduleId = c.getInt("scheduleId"),
                dayOfWeek = c.getInt("dayOfWeek"),
                subjectName = c.getString("subjectName"),
                subjectColor = c.getInt("subjectColor"),
                startTime = c.getString("startTime"),
                endTime = c.getString("endTime"),
                room = if (c.isNull("room")) null else c.getString("room"),
                type = c.getString("type"),
                attendanceStatus = c.getString("attendanceStatus"),
                attendancePercent = c.getString("attendancePercent").toDoubleOrNull() ?: 0.0,
                goalPercent = c.getString("goalPercent").toDoubleOrNull() ?: 75.0,
            )
        }
        val overallAttendance = obj.optString("overallAttendance", "0.0")
        WidgetData(cards, overallAttendance)
    } catch (_: Exception) {
        WidgetData(emptyList(), "0.0")
    }
}

/** Returns minutes since midnight for a "HH:mm" string. */
private fun timeToMinutes(time: String): Int {
    val parts = time.split(":")
    return parts[0].toIntOrNull()?.times(60)?.plus(parts[1].toIntOrNull() ?: 0) ?: 0
}

/** Converts Java Calendar.DAY_OF_WEEK (1=Sun..7=Sat) to Dart's weekday (1=Mon..7=Sun) */
private fun getDartWeekday(calendarDay: Int): Int {
    return if (calendarDay == Calendar.SUNDAY) 7 else calendarDay - 1
}

/** Picks the card to show: current active class, or the next upcoming one.
 * Returns Pair(card, remainingAfter). If showing tomorrow's class, remainingAfter = -1 (indicates tomorrow).
 */
private fun pickCurrentCard(allCards: List<ScheduleCard>): Pair<ScheduleCard?, Int> {
    if (allCards.isEmpty()) return Pair(null, 0)
    
    val cal = Calendar.getInstance()
    val nowMinutes = cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE)
    val todayDart = getDartWeekday(cal.get(Calendar.DAY_OF_WEEK))
    
    val todayCards = allCards.filter { it.dayOfWeek == todayDart }.sortedBy { timeToMinutes(it.startTime) }
    
    // Active class today
    val active = todayCards.firstOrNull { c ->
        timeToMinutes(c.startTime) <= nowMinutes && nowMinutes < timeToMinutes(c.endTime)
    }
    if (active != null) {
        return Pair(active, todayCards.count { timeToMinutes(it.startTime) > nowMinutes })
    }

    // Next upcoming today
    val upcomingToday = todayCards.firstOrNull { timeToMinutes(it.startTime) > nowMinutes }
    if (upcomingToday != null) {
        val remaining = todayCards.count { timeToMinutes(it.startTime) > timeToMinutes(upcomingToday.startTime) }
        return Pair(upcomingToday, remaining)
    }
    
    // If we're done for today, find tomorrow's (or next available day's) first class
    for (i in 1..7) {
        val nextDay = if ((todayDart + i) % 7 == 0) 7 else (todayDart + i) % 7
        val nextDayCards = allCards.filter { it.dayOfWeek == nextDay }.sortedBy { timeToMinutes(it.startTime) }
        if (nextDayCards.isNotEmpty()) {
            return Pair(nextDayCards.first(), -1) // -1 signifies "tomorrow / future day"
        }
    }
    
    return Pair(null, 0)
}

private fun attendanceColor(percent: Double, goal: Double): Color = when {
    percent >= goal -> Color(0xFF10B981.toInt())         // emerald
    percent >= goal * 0.9 -> Color(0xFFF59E0B.toInt())  // amber
    else -> Color(0xFFEF4444.toInt())                   // red
}

private fun typeIcon(type: String): String = when (type.lowercase()) {
    "lab" -> "🔬"
    "tutorial" -> "✏️"
    else -> "📚"
}

private fun statusBadge(status: String): String = when (status.lowercase()) {
    "present" -> "✓ Present"
    "absent" -> "✗ Absent"
    "medical" -> "🏥 Medical"
    "gt" -> "GT"
    "holiday" -> "🎉 Holiday"
    else -> ""
}

// ─── Widget ───────────────────────────────────────────────────────────────────

class AttendifyWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences(
            "HomeWidgetPreferences", Context.MODE_PRIVATE
        )
        val raw = prefs.getString("attendify_widget_data", null)
        val data = if (raw != null) parseWidgetData(raw) else WidgetData(emptyList(), "0.0")
        val (card, remainingAfter) = pickCurrentCard(data.cards)
        
        val todayDart = getDartWeekday(Calendar.getInstance().get(Calendar.DAY_OF_WEEK))
        val totalToday = data.cards.count { it.dayOfWeek == todayDart }

        val formatter = SimpleDateFormat("EEE, d MMM", Locale.getDefault())
        val dateFormatted = formatter.format(Calendar.getInstance().time)

        provideContent {
            GlanceTheme {
                WidgetContent(
                    context = context,
                    data = data,
                    dateFormatted = dateFormatted,
                    card = card,
                    totalToday = totalToday,
                    remainingAfter = remainingAfter,
                )
            }
        }
    }
}

@Composable
private fun WidgetContent(
    context: Context,
    data: WidgetData,
    dateFormatted: String,
    card: ScheduleCard?,
    totalToday: Int,
    remainingAfter: Int,
) {
    val bgGradientStart = Color(0xFF2D2880.toInt())
    val white           = Color.White
    val subduedWhite    = Color(0xB3FFFFFF.toInt()) // 70% white
    val cardBg          = Color(0x26FFFFFF.toInt()) // 15% white

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(bgGradientStart)
            .clickable(actionRunCallback<OpenAppCallback>())
            .padding(12.dp)
    ) {
        // ─── Header: Date & Overall Attendance ──────────────────────────────
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = "Today",
                    style = TextStyle(color = ColorProvider(subduedWhite), fontSize = 11.sp, fontWeight = FontWeight.Medium)
                )
                Text(
                    text = dateFormatted,
                    style = TextStyle(color = ColorProvider(white), fontSize = 15.sp, fontWeight = FontWeight.Bold)
                )
            }
            Spacer(GlanceModifier.defaultWeight())
            
            if (data.overallAttendance.isNotEmpty() && data.overallAttendance != "0.0") {
                val overallVal = data.overallAttendance.toDoubleOrNull() ?: 0.0
                val overallColor = attendanceColor(overallVal, 75.0)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "Overall: ",
                        style = TextStyle(color = ColorProvider(subduedWhite), fontSize = 11.sp)
                    )
                    Text(
                        text = "${data.overallAttendance}%",
                        style = TextStyle(color = ColorProvider(overallColor), fontSize = 14.sp, fontWeight = FontWeight.Bold)
                    )
                }
            }
        }

        Spacer(GlanceModifier.height(12.dp))

        // ─── Main Content Area ────────────────────────────────────────────────
        if (card == null) {
            // Empty state
            Box(
                modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = if (totalToday == 0) "No classes today 🎉" else "All done for today! 🎉",
                        style = TextStyle(color = ColorProvider(white), fontSize = 15.sp, fontWeight = FontWeight.Medium)
                    )
                    Spacer(GlanceModifier.height(4.dp))
                    Text(
                        text = "Tap to open Attendify",
                        style = TextStyle(color = ColorProvider(subduedWhite), fontSize = 11.sp)
                    )
                }
            }
        } else {
            // Class Card
            val attnColor = attendanceColor(card.attendancePercent, card.goalPercent)
            val subjectColor = Color(card.subjectColor)
            
            Column(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .defaultWeight()
                    .background(cardBg)
                    .padding(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Top row of card
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(modifier = GlanceModifier.size(10.dp).background(subjectColor)) {}
                    Spacer(GlanceModifier.width(8.dp))
                    Text(
                        text = "${typeIcon(card.type)} ${card.subjectName}",
                        style = TextStyle(color = ColorProvider(white), fontSize = 15.sp, fontWeight = FontWeight.Bold),
                        maxLines = 1,
                    )
                    Spacer(GlanceModifier.defaultWeight())
                    val badge = statusBadge(card.attendanceStatus)
                    if (badge.isNotEmpty()) {
                        Text(
                            text = badge,
                            style = TextStyle(color = ColorProvider(attnColor), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                        )
                    }
                }
                
                Spacer(GlanceModifier.height(6.dp))
                
                // Time & Room
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "⏰ ${card.startTime} – ${card.endTime}",
                        style = TextStyle(color = ColorProvider(subduedWhite), fontSize = 12.sp),
                    )
                    if (!card.room.isNullOrBlank()) {
                        Spacer(GlanceModifier.width(8.dp))
                        Text(
                            text = "• 📍 ${card.room}",
                            style = TextStyle(color = ColorProvider(subduedWhite), fontSize = 12.sp),
                            maxLines = 1,
                        )
                    }
                }
                
                Spacer(GlanceModifier.defaultWeight())
                
                // Subject Attendance
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Subject Attendance: ",
                        style = TextStyle(color = ColorProvider(subduedWhite), fontSize = 12.sp)
                    )
                    Text(
                        text = "${card.attendancePercent.toInt()}%",
                        style = TextStyle(color = ColorProvider(attnColor), fontSize = 13.sp, fontWeight = FontWeight.Bold)
                    )
                }
            }
            
            // Footer
            Spacer(GlanceModifier.height(8.dp))
            val footerText = when {
                remainingAfter == -1 -> "Showing next scheduled class"
                remainingAfter == 0 -> "Last class of the day"
                remainingAfter == 1 -> "1 upcoming class after this"
                else -> "$remainingAfter upcoming classes after this"
            }
            Text(
                text = footerText,
                style = TextStyle(color = ColorProvider(subduedWhite), fontSize = 10.sp),
            )
        }
    }
}

// ─── Action: open app on tap ──────────────────────────────────────────────────

class OpenAppCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        val intent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
        if (intent != null) context.startActivity(intent)
    }
}
