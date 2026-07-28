# Attendance Tracker
Version: 1.0
Platform: Android
Author: Lalit Jindal
Status: Product Requirements Document (PRD)

---

# 1. Product Vision

Attendance Tracker is a modern Android application designed specifically for college students who want complete control over their attendance.

Unlike traditional attendance apps that only calculate percentages, this application helps students plan their semester intelligently by combining attendance tracking, weekly timetable management, attendance forecasting, safe bunk prediction, analytics, and AI-powered recommendations into one seamless experience.

The application should feel premium, fast, intuitive, and distraction-free.

Primary Goal:
Help students maintain their desired attendance percentage with the least possible manual effort.

---

# 2. Problem Statement

Most colleges do not provide students with an easy way to track attendance.

Students generally:

- Forget whether they attended a lecture
- Calculate attendance manually
- Don't know how many classes they can skip
- Don't know how many classes they need to attend
- Lose track after medical leaves
- Can't differentiate Lecture and Lab attendance
- Don't have one place to manage the weekly timetable

Attendance management should be automatic after a one-time schedule setup.

---

# 3. Product Objectives

The application must:

✓ Reduce manual attendance calculations to zero.

✓ Automatically generate today's classes.

✓ Calculate attendance in real time.

✓ Predict future attendance.

✓ Tell students when they can safely bunk.

✓ Help students recover attendance before shortage occurs.

✓ Keep the interface minimal and enjoyable.

---

# 4. Target Audience

Primary Users

- Engineering Students
- Medical Students
- University Students
- Diploma Students

Age

17–28 Years

Experience Level

No technical knowledge required.

---

# 5. Core Features

### Dashboard

Today's schedule

Quick attendance marking

Today's summary

Upcoming class

Attendance warnings

Quick statistics

---

### Subject Management

Create subjects

Faculty information

Lecture/Lab classification

Credits

Color coding

Attendance goal

Minimum attendance requirement

Notes

---

### Weekly Schedule

One-time timetable setup

Weekly recurring schedule

Unlimited periods

Lecture and Lab support

Time conflict detection

Drag & Drop reordering

---

### Attendance Tracking

Per lecture attendance

Present

Absent

Medical

GT (Mass Bunk)

Pending

Holiday

Notes

Timestamp

---

### Analytics

Overall attendance

Subject attendance

Lecture attendance

Lab attendance

Weekly trends

Monthly trends

Attendance history

Safe bunk calculation

Classes needed

Prediction engine

Attendance goal comparison

---

### Calendar

Daily attendance

Attendance history

Holiday records

Attendance colors

Tap any day for details

---

### Settings

Semester dates

Attendance calculation rules

Medical policy

GT policy

Goal attendance

Export

Import

Theme

Backup

Restore

---

# 6. Attendance Status

| Status | Counts Towards Total | Counts As Present |
|---------|---------------------|-------------------|
| Present | Yes | Yes |
| Absent | Yes | No |
| Medical | Configurable | Configurable |
| GT | Configurable | Configurable |
| Holiday | No | No |
| Pending | No | No |

---

# 7. Attendance Formula

Attendance %

Present Classes / Total Classes × 100

Holiday is ignored.

Pending is ignored.

Medical and GT behaviour depends on settings.

---

# 8. Smart Prediction Engine

The application must automatically calculate

Current attendance

Target attendance

Remaining lectures

Safe bunks

Required lectures

Attendance after next lecture

Attendance after next absence

End-of-semester projected attendance

Risk level

No manual calculations should ever be required.

---

# 9. Smart Feedback System

The application continuously analyzes attendance.

Examples

"You must attend the next 5 DBMS lectures."

"You can safely miss 2 Operating System lectures."

"Java Lab attendance is below minimum."

"You will fall below 75% in approximately 9 lectures."

"Congratulations! Your overall attendance goal has been achieved."

Feedback should update immediately after every attendance change.

---

# 10. Dashboard

The Dashboard is the primary screen.

It should always display today's schedule.

Every lecture card contains:

Subject

Faculty

Room

Start Time

End Time

Lecture/Lab

Attendance Buttons

Present

Absent

Medical

GT

Pending

The card should visually update after marking attendance.

---

# 11. Mark Entire Day as Holiday

User taps:

Mark Today as Holiday

Popup appears

Fields

Holiday Reason

Optional Notes

Confirm

After confirmation

All today's lectures become Holiday.

Attendance calculations remain unchanged.

Calendar records holiday.

Analytics ignore those lectures.

---

# 12. Subject Details

Each subject contains

Subject Name

Faculty

Email

Phone

Credits

Lecture

Lab

Attendance Goal

Minimum Requirement

Color

Notes

Statistics

Total

Present

Absent

Medical

GT

Holiday

Attendance %

Safe Bunks

Required Lectures

History

---

# 13. Weekly Timetable

The timetable repeats automatically every week.

User configures only once.

Supported

Monday

Tuesday

Wednesday

Thursday

Friday

Saturday

Sunday

Every lecture stores

Subject

Start Time

End Time

Faculty

Room

Lecture/Lab

Color

---

# 14. Analytics Dashboard

Overall Attendance Card

Overall Goal Card

Total Lectures

Present

Absent

Medical

GT

Holiday

Remaining Semester Lectures

Progress Ring

Attendance Trend

Subject Cards

Every subject displays

Attendance %

Target %

Safe Bunks

Required Classes

Risk Level

Lecture Attendance

Lab Attendance

Trend

---

# 15. Attendance Simulator (What-If)

Students can simulate future attendance.

Inputs

Subject

Attend Next N Classes

Miss Next N Classes

Outputs

New Attendance %

Remaining Safe Bunks

Classes Needed

Target Achievement Date

---

# 16. Search

Search

Subject

Faculty

Attendance

Date

Notes

Results should appear instantly.

---

# 17. Notifications

Upcoming lecture reminder

Attendance below target

Goal achieved

Safe bunk available

Missing attendance entry reminder

Daily attendance reminder

Notification timing should be configurable.

---

# 18. Offline Support

The application must work completely offline.

All attendance should be stored locally.

If cloud sync is enabled in future versions, synchronization should occur automatically when an internet connection becomes available.

Offline-first architecture is mandatory.

---

# 19. Functional Requirements

FR-001

User can create subjects.

FR-002

User can edit subjects.

FR-003

User can delete subjects.

FR-004

User can create weekly timetable.

FR-005

Dashboard automatically loads today's classes.

FR-006

Attendance can be marked using one tap.

FR-007

Attendance percentages update instantly.

FR-008

Analytics update immediately.

FR-009

Holiday should ignore attendance calculations.

FR-010

Prediction engine updates in real time.

FR-011

Lecture and Lab attendance must be tracked separately and together.

FR-012

Users can set custom attendance goals globally and per subject.

---

# 20. Non-Functional Requirements

Application launch < 2 seconds

Attendance update < 100 ms

Smooth 60 FPS animations

Works offline

Supports Android 9+

Battery efficient

Dark mode

Material Design 3

No advertisements

No mandatory login

Local encrypted database

---

# 21. Future Scope

Google Calendar integration

Faculty timetable sharing

Widgets

Semester planner

Cloud Backup

Wear OS support

Barcode attendance

NFC attendance

QR attendance

AI Study Planner

AI Attendance Assistant

Smart timetable import from PDF

Automatic holiday detection

College ERP integration

Multi-semester support

CGPA tracker

Assignment tracker

Exam planner

---

# 22. Success Metrics

Daily active usage

Average attendance entries per week

Attendance prediction accuracy

Percentage of missed attendance entries

User retention

Crash-free sessions > 99.9%

App startup time

Battery usage
