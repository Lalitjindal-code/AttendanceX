package com.lalitjindal.attendify.widget

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.LinearProgressIndicator
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
    val isAmoled: Boolean,
    val isDarkMode: Boolean,
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
        val isAmoled = obj.optBoolean("isAmoled", false)
        val isDarkMode = obj.optBoolean("isDarkMode", true)
        WidgetData(cards, overallAttendance, isAmoled, isDarkMode)
    } catch (_: Exception) {
        WidgetData(emptyList(), "0.0", false, true)
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
        val data = if (raw != null) parseWidgetData(raw) else WidgetData(emptyList(), "0.0", false, true)
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
    // ─── Resolve Colors based on active theme mode ────────────────────────────
    val isLight = !data.isDarkMode
    val isAmoled = data.isDarkMode && data.isAmoled

    // Background color
    val widgetBgColor = when {
        isLight -> Color(0xFFF5F4FA.toInt())
        isAmoled -> Color(0xFF000000.toInt())
        else -> Color(0xFF0B0B13.toInt()) // Standard dark
    }

    // Text colors
    val mainTextColor = if (isLight) Color(0xFF1D1B20.toInt()) else Color.White
    val subTextColor = if (isLight) Color(0xFF49454F.toInt()) else Color(0xB3FFFFFF.toInt()) // 70% white

    // Card background & borders
    val cardBackground = when {
        isLight -> Color(0xFFFFFFFF.toInt())
        isAmoled -> Color(0xFF0E0E1E.toInt())
        else -> Color(0xFF16162C.toInt())
    }

    val cardBorderColor = when {
        isLight -> Color(0xFFE8E7F5.toInt())
        isAmoled -> Color(0xFF2A2850.toInt())
        else -> Color(0xFF3A3850.toInt())
    }

    val widgetModifier = GlanceModifier
        .fillMaxSize()
        .clickable(actionRunCallback<OpenAppCallback>())
        .cornerRadius(16.dp)

    // Layout Nesting for outer widget border (AMOLED Mode)
    val outerModifier = if (isAmoled) {
        widgetModifier
            .background(Color(0xFF1C1C30.toInt()))
            .padding(1.dp)
    } else {
        widgetModifier
    }

    val innerBgColor = if (isAmoled) Color(0xFF000000.toInt()) else widgetBgColor
    val innerCornerRadius = if (isAmoled) 15.dp else 16.dp

    Box(modifier = outerModifier) {
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(innerBgColor)
                .cornerRadius(innerCornerRadius)
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
                        style = TextStyle(color = ColorProvider(subTextColor), fontSize = 11.sp, fontWeight = FontWeight.Medium)
                    )
                    Row(
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = dateFormatted,
                            style = TextStyle(color = ColorProvider(mainTextColor), fontSize = 15.sp, fontWeight = FontWeight.Bold)
                        )
                        Spacer(GlanceModifier.width(8.dp))
                        Text(
                            text = "🔄",
                            style = TextStyle(color = ColorProvider(subTextColor), fontSize = 14.sp),
                            modifier = GlanceModifier.clickable(actionRunCallback<RefreshWidgetAction>())
                        )
                    }
                }
                Spacer(GlanceModifier.defaultWeight())
                
                if (data.overallAttendance.isNotEmpty() && data.overallAttendance != "0.0") {
                    val overallVal = data.overallAttendance.toDoubleOrNull() ?: 0.0
                    val overallColor = attendanceColor(overallVal, 75.0)
                    
                    // Capsule layout for overall attendance
                    Row(
                        modifier = GlanceModifier
                            .background(if (isLight) Color(0xFFECEBFC.toInt()) else Color(0x1F7E73FF.toInt()))
                            .cornerRadius(12.dp)
                            .padding(horizontal = 8.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Overall: ",
                            style = TextStyle(color = ColorProvider(subTextColor), fontSize = 10.sp, fontWeight = FontWeight.Medium)
                        )
                        Text(
                            text = "${data.overallAttendance}%",
                            style = TextStyle(color = ColorProvider(overallColor), fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        )
                    }
                }
            }

            Spacer(GlanceModifier.height(10.dp))

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
                            style = TextStyle(color = ColorProvider(mainTextColor), fontSize = 15.sp, fontWeight = FontWeight.Medium)
                        )
                        Spacer(GlanceModifier.height(4.dp))
                        Text(
                            text = "Tap to open Attendify",
                            style = TextStyle(color = ColorProvider(subTextColor), fontSize = 11.sp)
                        )
                    }
                }
            } else {
                // Class Card wrapped in Box for border
                val attnColor = attendanceColor(card.attendancePercent, card.goalPercent)
                val subjectColor = Color(card.subjectColor)
                
                Box(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .defaultWeight()
                        .background(cardBorderColor)
                        .cornerRadius(16.dp)
                        .padding(1.dp)
                ) {
                    Box(
                        modifier = GlanceModifier
                            .fillMaxSize()
                            .background(cardBackground)
                            .cornerRadius(15.dp)
                    ) {
                        Row(
                            modifier = GlanceModifier.fillMaxSize()
                        ) {
                            // Left indicator strip
                            Box(
                                modifier = GlanceModifier
                                    .width(5.dp)
                                    .fillMaxHeight()
                                    .background(subjectColor)
                            ) {}
                            
                            // Card Details
                            Column(
                                modifier = GlanceModifier
                                    .defaultWeight()
                                    .fillMaxHeight()
                                    .padding(12.dp)
                            ) {
                                // Top row: Icon + Subject Name, Status badge chip
                                Row(
                                    modifier = GlanceModifier.fillMaxWidth(),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = "${typeIcon(card.type)} ${card.subjectName}",
                                        style = TextStyle(color = ColorProvider(mainTextColor), fontSize = 14.sp, fontWeight = FontWeight.Bold),
                                        maxLines = 1,
                                    )
                                    Spacer(GlanceModifier.defaultWeight())
                                    
                                    val badge = statusBadge(card.attendanceStatus)
                                    if (badge.isNotEmpty()) {
                                        Box(
                                            modifier = GlanceModifier
                                                .background(if (isLight) Color(0xFFF1F0FF.toInt()) else Color(0x157E73FF.toInt()))
                                                .cornerRadius(8.dp)
                                                .padding(horizontal = 6.dp, vertical = 2.dp)
                                        ) {
                                            Text(
                                                text = badge,
                                                style = TextStyle(color = ColorProvider(attnColor), fontSize = 10.sp, fontWeight = FontWeight.Bold)
                                            )
                                        }
                                    }
                                }
                                
                                Spacer(GlanceModifier.height(4.dp))
                                
                                // Time & Room
                                Row(
                                    modifier = GlanceModifier.fillMaxWidth(),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = "⏰ ${card.startTime} – ${card.endTime}",
                                        style = TextStyle(color = ColorProvider(subTextColor), fontSize = 11.sp),
                                    )
                                    if (!card.room.isNullOrBlank()) {
                                        Spacer(GlanceModifier.width(8.dp))
                                        Text(
                                            text = "📍 ${card.room}",
                                            style = TextStyle(color = ColorProvider(subTextColor), fontSize = 11.sp),
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
                                        text = "${card.attendancePercent.toInt()}% Attended",
                                        style = TextStyle(color = ColorProvider(mainTextColor), fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                    )
                                    Spacer(GlanceModifier.defaultWeight())
                                    Text(
                                        text = "Goal: ${card.goalPercent.toInt()}%",
                                        style = TextStyle(color = ColorProvider(subTextColor), fontSize = 10.sp)
                                    )
                                }
                                
                                Spacer(GlanceModifier.height(4.dp))
                                
                                // Progress Bar
                                val progressFraction = (card.attendancePercent / 100.0).toFloat().coerceIn(0f, 1f)
                                LinearProgressIndicator(
                                    progress = progressFraction,
                                    modifier = GlanceModifier.fillMaxWidth().height(4.dp).cornerRadius(2.dp),
                                    color = ColorProvider(attnColor),
                                    backgroundColor = ColorProvider(if (isLight) Color(0xFFECEBFC.toInt()) else Color(0xFF2A2850.toInt()))
                                )
                            }
                        }
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
                    style = TextStyle(color = ColorProvider(subTextColor), fontSize = 10.sp),
                )
            }
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

class RefreshWidgetAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters,
    ) {
        val pendingIntent = es.antonborri.home_widget.HomeWidgetBackgroundIntent.getBroadcast(
            context,
            android.net.Uri.parse("attendify://refresh")
        )
        try {
            pendingIntent.send()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
