package com.lalitjindal.attendify.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

/**
 * Android BroadcastReceiver that serves as the entry point for the Attendify
 * home screen widget.
 *
 * Registered in AndroidManifest.xml with the APPWIDGET_UPDATE intent filter.
 */
class AttendifyWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = AttendifyWidget()

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        // Schedule per-period WorkManager jobs whenever the widget is updated/added
        WidgetScheduler.scheduleAll(context)
    }
}
