# PHASES.md

Project: Attendance Tracker
Platform: Android
Version: 1.0

---

# Development Strategy

Development should follow an MVP-first approach.

Goal:

Ship a fully working application as quickly as possible.

Avoid overengineering.

Every phase should produce a usable application.

---

# Overall Timeline

Phase 1 → Project Foundation

Phase 2 → Subject Management

Phase 3 → Weekly Schedule

Phase 4 → Attendance Tracking

Phase 5 → Analytics Engine

Phase 6 → Calendar & History

Phase 7 → Notifications

Phase 8 → Settings & Backup

Phase 9 → UI Polish

Phase 10 → Testing & Release

---

# Phase 1
## Project Foundation

### Goal

Create the base application.

### Tasks

- Flutter project setup
- Material 3
- Dark Mode
- Riverpod
- Go Router
- Isar setup
- Theme configuration
- Folder structure
- Reusable widgets
- Navigation
- App Icons
- Splash Screen

### Deliverables

✓ Application launches

✓ Navigation works

✓ Database initialized

✓ Theme switching works

---

# Phase 2
## Subject Management

### Goal

Manage all subjects.

### Features

Add Subject

Edit Subject

Delete Subject

Search Subject

Subject Details

Faculty Details

Attendance Goal

Lecture/Lab

Notes

Color Picker

Credits

Minimum Attendance

### Validation

No duplicate subject names

Required fields validation

### Deliverables

✓ Subject CRUD completed

✓ Search working

✓ Validation working

---

# Phase 3
## Weekly Schedule

### Goal

Create recurring timetable.

### Features

Monday-Sunday

Unlimited lectures

Lecture/Lab

Room Number

Faculty

Time

Subject Selection

Drag & Drop

Conflict Detection

Edit

Delete

### Deliverables

✓ Weekly timetable completed

✓ Schedule repeats automatically

✓ Time sorting working

---

# Phase 4
## Attendance Tracking

### Goal

Track attendance daily.

### Dashboard

Today's schedule

Today's summary

Upcoming lecture

Attendance cards

### Attendance Status

Present

Absent

Medical

GT

Pending

Holiday

### Features

One tap attendance

Undo attendance

Edit attendance

Attendance history

Holiday dialog

Holiday reason

Quick attendance

### Deliverables

✓ Dashboard completed

✓ Attendance saved

✓ Holiday flow completed

---

# Phase 5
## Analytics Engine

### Goal

Generate attendance statistics.

### Features

Overall attendance

Subject attendance

Lecture attendance

Lab attendance

Progress Ring

Pie Chart

Bar Chart

Weekly Trend

Monthly Trend

Safe Bunks

Classes Needed

Prediction Engine

Attendance Simulator

### Smart Cards

Low Attendance

Goal Achieved

Need Classes

Safe Bunks

### Deliverables

✓ Analytics page complete

✓ Algorithms completed

✓ Charts working

---

# Phase 6
## Calendar & History

### Goal

View attendance history.

### Features

Monthly Calendar

Attendance Colors

Holiday View

Daily Details

Attendance Timeline

Edit Attendance

Filter

Search

### Deliverables

✓ Calendar working

✓ History working

---

# Phase 7
## Notifications

### Goal

Remind users.

### Notifications

Upcoming lecture

Daily attendance reminder

Low attendance

Goal completed

Safe bunk available

Missing attendance

### Settings

Enable

Disable

Time

Reminder before lecture

### Deliverables

✓ Local notifications working

---

# Phase 8
## Settings & Backup

### Goal

Application customization.

### Features

Theme

Dark Mode

Attendance Rules

Medical Rules

GT Rules

Goal %

Semester Dates

Backup

Restore

Export JSON

Import JSON

Reset

About

Privacy Policy

### Deliverables

✓ Settings completed

✓ Export Import working

---

# Phase 9
## UI Polish

### Goal

Make application premium.

### Improvements

Animations

Transitions

Skeleton Loaders

Empty States

Icons

Spacing

Typography

Dark Theme Polish

Accessibility

Performance

Micro Animations

Haptic Feedback

### Deliverables

✓ Premium UI

✓ Smooth experience

---

# Phase 10
## Testing & Release

### Goal

Prepare production release.

### Testing

Subject CRUD

Schedule

Attendance

Analytics

Holiday

Backup

Notifications

Dark Mode

Performance

Offline

### Bug Fixes

Crash fixes

Memory leaks

Optimization

### Release

Android APK

Play Store Bundle

Version 1.0

---

# Milestone Checklist

## Milestone 1

Project Ready

- Navigation
- Theme
- Database

---

## Milestone 2

Subject Module Complete

- CRUD
- Search
- Validation

---

## Milestone 3

Timetable Ready

- Weekly Schedule
- Drag Drop
- Conflict Detection

---

## Milestone 4

Attendance Ready

- Dashboard
- Daily Attendance
- Holiday
- History

---

## Milestone 5

Analytics Ready

- Charts
- Prediction
- Safe Bunk
- Simulator

---

## Milestone 6

Calendar Ready

- Calendar
- Timeline
- Filters

---

## Milestone 7

Production Ready

- Notifications
- Backup
- Polish
- Testing

---

# MVP Scope (Version 1.0)

These features **must** be completed before release.

## Included

✅ Subject Management

✅ Weekly Timetable

✅ Dashboard

✅ Attendance Tracking

✅ Holiday Management

✅ Analytics

✅ Attendance Prediction

✅ Safe Bunk Calculator

✅ Calendar

✅ Search

✅ Notifications

✅ Settings

✅ Offline Database

✅ Export / Import

---

# Post MVP (Version 1.1)

- Material You Dynamic Colors
- Widgets
- Semester Archive
- Better Charts
- Multiple Timetables
- Attendance Notes
- Attendance Filters
- Custom Icons
- CSV Export

---

# Version 1.2

- Google Drive Backup
- Supabase Sync
- Multiple Semesters
- Attendance Sharing
- PDF Reports
- Advanced Analytics
- Faculty-wise Reports

---

# Version 2.0

- AI Attendance Assistant
- AI Semester Planner
- OCR Timetable Import
- PDF Timetable Import
- QR Attendance
- College ERP Integration
- Google Calendar Sync
- Smart Attendance Suggestions
- Wear OS Support

---

# Definition of Done (DoD)

A phase is considered complete only if:

✓ Feature works without crashes

✓ UI follows Design System

✓ Responsive on supported devices

✓ Dark Mode supported

✓ Data persists correctly

✓ Validation implemented

✓ No major bugs

✓ Code reviewed

✓ No hardcoded values

✓ Performance acceptable

✓ Documentation updated

---

# Risk Register

## High Risk

- Incorrect attendance calculations
- Data corruption
- Schedule conflicts
- Notification reliability

Mitigation:
- Unit tests
- Validation
- Repository pattern
- Backup support

---

## Medium Risk

- UI inconsistency
- Performance degradation
- Large attendance history

Mitigation:
- Reusable components
- Database indexing
- Lazy loading

---

## Low Risk

- Theme issues
- Minor animations
- Typography inconsistencies

---

# Release Checklist

Before v1.0 release ensure:

- App icon added
- Splash screen added
- No debug logs
- No placeholder data
- Version number updated
- Backup tested
- Restore tested
- Analytics verified
- Notifications verified
- Dark mode verified
- Offline mode verified
- APK generated
- Release build tested
- Crash-free smoke test completed

---

# Success Criteria

The application is successful if a student can:

✓ Add all subjects

✓ Create one weekly timetable

✓ Mark attendance in under 5 seconds

✓ View today's schedule instantly

✓ Know current attendance immediately

✓ Know how many classes to attend

✓ Know how many classes can be skipped

✓ View complete attendance history

✓ Export and restore data without losing records

If all of the above are possible smoothly and offline, Version 1.0 is considered complete.
