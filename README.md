# Attendify (formerly AttendanceX)

Attendify is a production-grade, offline-first Flutter application designed for students to track their academic attendance with precision, smart analytics, and a buttery smooth user interface. 

## 🚀 Key Features

*   **Smart Dashboard**: A beautifully animated dashboard that cleanly separates your upcoming classes ("Pending") from the ones you've already completed ("Marked").
*   **Granular Attendance Statuses**: Track attendance with high specificity: Present, Absent, GT (Duty Leave), Medical Leave, and Holidays.
*   **Analytics & Smart Suggestions**: 
    *   Powered by the robust `AttendanceEngine`, the app dynamically calculates effective percentages based on your custom rules (e.g., whether Medical Leaves count as present, or how GT leaves are treated).
    *   Provides actionable insights like "Safe Bunks Available" or "Classes to Attend" to hit your target goal.
*   **Offline-First & Lightning Fast**: Built on top of **Isar NoSQL**, ensuring that all data operations are instantaneous and strictly offline. 
*   **Highly Customisable Settings**: Set your target percentage (e.g., 75%), adjust semester dates, and toggle specific attendance calculation rules.
*   **Beautiful UI/UX**: Built with implicit animations, smooth transitions, haptic feedback, and a strictly enforced Material 3 design system.

## 🛠 Tech Stack

*   **Framework**: Flutter (Dart)
*   **State Management**: Riverpod (`flutter_riverpod` + `riverpod_annotation`)
*   **Database**: Isar Database (Offline NoSQL)
*   **Architecture**: Modular layer-based architecture (Repositories, Providers, Engines, and UI Features).

## 📂 Architecture Overview

The app follows a structured design separating business logic from presentation:
*   **`/database`**: Contains Isar collections (`Subject`, `Schedule`, `Attendance`) and Repositories.
*   **`/engines`**: Core business logic modules (e.g. `AttendanceEngine`) that are entirely decoupled from UI and State Management. These are highly testable pure Dart classes.
*   **`/features`**: UI code separated by domain (`dashboard`, `analytics`, `calendar`, `settings`, `subjects`, `schedule`), each containing its own screens, widgets, and Riverpod providers.
*   **`/core`**: Enums, Theme data, extensions (e.g. `AttendanceStatusUI`), and configuration.

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (v3.19+)
*   Dart SDK

### Installation

1.  **Clone the repository**
2.  **Install dependencies**
    ```bash
    flutter pub get
    ```
3.  **Generate Isar & Riverpod files** (If you modify models or providers)
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the App**
    ```bash
    flutter run
    ```

## 📝 Testing

The project includes Unit Tests and Widget Tests (including Golden tests using `golden_toolkit`):
```bash
flutter test
```

## ✨ Recent Updates
* **Dashboard Overhaul**: Seamlessly split Pending vs Marked classes with dynamic progress rings, clean badges, and reusable BottomSheets.
* **Date Sync Fixes**: Improved time-zone resilient UTC/Local `DateTime` comparisons for daily tracking!
