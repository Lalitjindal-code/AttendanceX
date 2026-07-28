# DESIGN_SYSTEM.md

Project: Attendance Tracker
Version: 1.0
Platform: Android
Design Language: Material Design 3 + Modern Minimalism

---

# 1. Design Philosophy

The application should feel like a premium productivity app instead of a college project.

Design Principles

• Clean
• Minimal
• Fast
• Calm
• Modern
• Highly Readable
• Touch Friendly
• Consistent

The interface should reduce cognitive load.

Everything important should be reachable within one or two taps.

---

# 2. Design Keywords

Minimal

Premium

Organized

Professional

Smooth

Friendly

Modern

Glass-free

No visual clutter

---

# 3. Design Inspiration

Google Calendar

TickTick

Notion

Todoist

Linear

GitHub Mobile

Google Tasks

Material You

The app should feel like these apps, not like a typical attendance calculator.

---

# 4. Theme

Material Design 3

Support

✓ Light Theme

✓ Dark Theme

✓ Follow System Theme

---

# 5. Color Palette

## Primary

Blue 600

Used For

Primary Buttons

FAB

Highlights

Progress

Charts

---

## Secondary

Purple

Used For

Analytics

Cards

Charts

---

## Success

Green

Used For

Present

Completed

Safe Attendance

---

## Error

Red

Used For

Absent

Danger

Delete

---

## Warning

Orange

Used For

Medical

Warning

Low Attendance

---

## Info

Sky Blue

Used For

GT

Notifications

Information

---

## Holiday

Grey

Used For

Holiday

Disabled

History

---

# Attendance Status Colors

Present → Green

Absent → Red

Medical → Orange

GT → Blue

Holiday → Grey

Pending → Yellow

These colors must remain consistent throughout the application.

---

# 6. Typography

Use

Google Font

Inter

Fallback

Roboto

---

Display Large

Used For

Splash

Large Numbers

Attendance %

---

Headline

Used For

Screen Titles

---

Title

Used For

Cards

Dialogs

Bottom Sheets

---

Body

Used For

Normal Text

---

Label

Used For

Buttons

Small Chips

Tags

---

Rules

Never use more than five font sizes.

Avoid bold everywhere.

Use whitespace instead.

---

# 7. Spacing System

Use 8-point grid.

Spacing

4

8

12

16

20

24

32

40

48

Never use random spacing.

---

# 8. Corner Radius

Small Components

8

Cards

16

Dialogs

20

Bottom Sheet

24

FAB

16

Buttons

14

---

# 9. Shadows

Very subtle.

Never heavy.

Cards should appear elevated but soft.

Dark mode uses even softer elevation.

---

# 10. Icons

Use

Material Symbols Rounded

Avoid mixing icon packs.

Every icon should have equal visual weight.

Examples

Dashboard

Calendar

Analytics

Schedule

Subjects

Holiday

Present

Absent

Settings

Search

Notifications

---

# 11. Navigation

Bottom Navigation

Exactly five tabs.

1

Dashboard

2

Subjects

3

Schedule

4

Analytics

5

Settings

Calendar should be accessible from Dashboard and Analytics instead of occupying a permanent tab.

---

# 12. Screen Structure

Each screen

Top App Bar

↓

Content

↓

Floating Action Button (if required)

↓

Bottom Navigation

No nested navigation unless necessary.

---

# 13. Dashboard Design

Top

Greeting

Today's Date

Overall Attendance Ring

Quick Summary

↓

Today's Schedule

↓

Attendance Cards

↓

Upcoming Lecture

↓

Smart Suggestion Card

↓

FAB

---

# 14. Subject Screen

Search Bar

↓

Subject Cards

↓

Floating Action Button

Add Subject

Subject Card

Subject Name

Faculty

Attendance %

Goal %

Safe Bunks

Quick Actions

Edit

Delete

Details

---

# 15. Schedule Screen

Week Selector

↓

Monday

↓

Lecture Cards

↓

Tuesday

↓

Lecture Cards

Repeat...

FAB

Add Lecture

Support drag-and-drop reordering.

---

# 16. Analytics Screen

Overall Attendance Ring

↓

Attendance Trend

↓

Subject Statistics

↓

Charts

↓

Prediction Card

↓

Safe Bunk Card

↓

Attendance Simulator

---

# 17. Settings Screen

Grouped Sections

General

Appearance

Attendance Rules

Notifications

Backup

About

No endless scrolling.

---

# 18. Card Design

Cards are the main building block.

Card contains

Icon

Title

Subtitle

Supporting Information

Action Buttons

Cards should never look crowded.

---

# 19. Buttons

Primary

Filled

Used

Save

Create

Done

---

Secondary

Outlined

Used

Cancel

Edit

Filter

---

Text Button

Used

Dismiss

Back

Learn More

---

Danger

Filled Red

Used

Delete

Reset

---

# 20. Floating Action Button

Only one FAB per screen.

Dashboard

Quick Attendance

Subjects

Add Subject

Schedule

Add Lecture

Analytics

No FAB

Settings

No FAB

---

# 21. Attendance Card

Each lecture card shows

Subject

Faculty

Time

Room

Lecture/Lab Badge

Attendance Buttons

Present

Absent

Medical

GT

Pending

Buttons should be large enough for one-handed use.

---

# 22. Progress Indicators

Circular Progress

Overall Attendance

Linear Progress

Goal Tracking

Animated on update.

---

# 23. Charts

Pie Chart

Attendance Distribution

Bar Chart

Subject Comparison

Line Chart

Weekly Trend

Calendar Heatmap

Monthly History

Charts should use consistent colors.

---

# 24. Dialog Design

Rounded

Large Buttons

Simple Layout

No more than two actions.

Examples

Delete Subject

Holiday Reason

Reset Data

Edit Attendance

---

# 25. Bottom Sheet

Used For

Attendance Details

Subject Details

Lecture Details

Filters

Should occupy around 70% of screen height.

---

# 26. Chips

Used For

Lecture

Lab

Holiday

Goal

Present

Absent

Medical

GT

Rounded appearance.

---

# 27. Snackbars

Short

Informative

Examples

Attendance Updated

Subject Deleted

Holiday Added

Settings Saved

Duration

2–3 seconds

---

# 28. Empty States

Every screen needs one.

No Subjects

Illustration

Message

Button

Create Subject

No Schedule

Create Timetable

No Attendance

Mark Attendance

No Analytics

Start Tracking

---

# 29. Loading States

Use Skeleton Loaders

Never spinning loader unless absolutely necessary.

---

# 30. Animations

Fast

Smooth

Purposeful

Duration

200–300 ms

Use animations for

Card Expansion

Attendance Update

Screen Transition

Chart Update

Button Press

Avoid flashy animations.

---

# 31. Gesture Support

Tap

Long Press

Swipe

Drag

Examples

Swipe Attendance Card

Quick Mark

Long Press

Edit Attendance

Drag

Reorder Schedule

---

# 32. Accessibility

Touch targets

Minimum 48dp

Support screen readers

High contrast

Scalable fonts

Meaningful labels

Do not rely on color alone.

---

# 33. Dark Mode

Every component must support Dark Mode.

No pure black.

Use dark grey surfaces.

Charts should remain readable.

---

# 34. Micro Interactions

When attendance marked

✓ Button animates

✓ Card color changes

✓ Progress updates

✓ Snackbar appears

✓ Analytics refresh

Instant feedback is essential.

---

# 35. Haptic Feedback

Use subtle vibration for

Attendance Marked

Delete Confirmation

Holiday Added

Long Press

Avoid excessive haptics.

---

# 36. Responsive Layout

Support

Small Phones

Normal Phones

Large Phones

Foldables (basic support)

Portrait-first.

Landscape support can come later.

---

# 37. Illustration Style

Flat

Minimal

Google-style

Friendly

Used only for

Empty States

Welcome Screen

No cartoon characters.

---

# 38. Premium Feel Checklist

✓ Consistent spacing

✓ Smooth animations

✓ Soft shadows

✓ Large touch targets

✓ Material 3

✓ Clean cards

✓ No clutter

✓ Fast interactions

✓ Minimal dialogs

✓ Beautiful typography

✓ Consistent colors

✓ Meaningful icons

✓ Modern navigation

---

# 39. UI Components Inventory

Global Components

• App Bar

• Bottom Navigation

• FAB

• Card

• Subject Card

• Attendance Card

• Analytics Card

• Progress Ring

• Buttons

• Text Fields

• Search Bar

• Chips

• Dialog

• Bottom Sheet

• Snackbar

• Calendar Cell

• Chart Widget

• Empty State Widget

• Loading Skeleton

• Section Header

• Statistics Tile

• Info Banner

These components should be reusable across the app.

---

# 40. Future UI Enhancements

• Dynamic Material You Colors

• Home Screen Widgets

• Semester Dashboard

• Interactive Calendar

• Attendance Timeline

• Advanced Animations

• Tablet Layout

• Wear OS Companion

• Multiple Color Themes

• AI Insights Cards