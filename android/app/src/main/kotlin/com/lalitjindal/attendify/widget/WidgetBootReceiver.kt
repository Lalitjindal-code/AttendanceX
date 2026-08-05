package com.lalitjindal.attendify.widget

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Reschedules WorkManager widget-update jobs after device reboot.
 *
 * WorkManager jobs do not survive reboots by default, so this receiver
 * re-enqueues them via [WidgetScheduler.scheduleAll].
 */
class WidgetBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON"
        ) {
            WidgetScheduler.scheduleAll(context)
        }
    }
}
