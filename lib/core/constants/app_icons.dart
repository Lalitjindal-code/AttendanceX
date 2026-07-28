import 'package:flutter/material.dart';

/// Centralised icon references for the application.
///
/// All [IconData] values must come from this class.
/// Uses Material Rounded icons for visual consistency across the app.
abstract final class AppIcons {
  AppIcons._();

  // ── Navigation ────────────────────────────────────────────────────────────────
  static const IconData dashboard = Icons.dashboard_rounded;
  static const IconData dashboardOutlined = Icons.dashboard_outlined;
  static const IconData subjects = Icons.book_rounded;
  static const IconData subjectsOutlined = Icons.book_outlined;
  static const IconData schedule = Icons.calendar_today_rounded;
  static const IconData scheduleOutlined = Icons.calendar_today_outlined;
  static const IconData analytics = Icons.bar_chart_rounded;
  static const IconData analyticsOutlined = Icons.bar_chart_outlined;
  static const IconData settings = Icons.settings_rounded;
  static const IconData settingsOutlined = Icons.settings_outlined;

  // ── Actions ───────────────────────────────────────────────────────────────────
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_ios_rounded;
  static const IconData more = Icons.more_vert_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData dragHandle = Icons.drag_handle_rounded;
  static const IconData share = Icons.share_rounded;

  // ── Attendance Status Icons ────────────────────────────────────────────────────
  static const IconData present = Icons.check_circle_rounded;
  static const IconData absent = Icons.cancel_rounded;
  static const IconData medical = Icons.local_hospital_rounded;
  static const IconData gt = Icons.verified_rounded;
  static const IconData holiday = Icons.beach_access_rounded;
  static const IconData pending = Icons.radio_button_unchecked_rounded;

  // ── Subject & Schedule ────────────────────────────────────────────────────────
  static const IconData subject = Icons.menu_book_rounded;
  static const IconData faculty = Icons.person_rounded;
  static const IconData credits = Icons.stars_rounded;
  static const IconData color = Icons.palette_rounded;
  static const IconData goal = Icons.flag_rounded;
  static const IconData room = Icons.location_on_rounded;
  static const IconData time = Icons.access_time_rounded;
  static const IconData lecture = Icons.school_rounded;
  static const IconData lab = Icons.science_rounded;
  static const IconData tutorial = Icons.psychology_rounded;

  // ── Analytics ─────────────────────────────────────────────────────────────────
  static const IconData trend = Icons.trending_up_rounded;
  static const IconData prediction = Icons.auto_graph_rounded;
  static const IconData safeBunk = Icons.thumb_up_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData danger = Icons.error_rounded;
  static const IconData percent = Icons.percent_rounded;

  // ── Settings ──────────────────────────────────────────────────────────────────
  static const IconData darkMode = Icons.dark_mode_rounded;
  static const IconData lightMode = Icons.light_mode_rounded;
  static const IconData systemMode = Icons.brightness_auto_rounded;
  static const IconData notifications = Icons.notifications_rounded;
  static const IconData backup = Icons.backup_rounded;
  static const IconData restore = Icons.restore_rounded;
  static const IconData info = Icons.info_outline_rounded;

  // ── Misc ──────────────────────────────────────────────────────────────────────
  static const IconData calendar = Icons.calendar_month_rounded;
  static const IconData phone = Icons.phone_rounded;
  static const IconData email = Icons.email_rounded;
  static const IconData note = Icons.sticky_note_2_rounded;
  static const IconData history = Icons.history_rounded;
  static const IconData chevronRight = Icons.chevron_right_rounded;
  static const IconData chevronDown = Icons.expand_more_rounded;
}
