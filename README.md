# 📝 Notes Manager App

A Flutter-based notes and task management application with due-date reminders, favorites, progress tracking, and smart filtering — built on Firebase Firestore for real-time data sync and `flutter_local_notifications` for scheduled alerts.

##  Demo Video

Watch the app in action: [https://youtu.be/8fhllntQxwA](https://youtu.be/8fhllntQxwA?si=XsZzZ8MDdp6qmoOP)

##  Features

- **Create, edit, and delete notes** — each with a title, description, due date, and due time
- **Task progress tracking** — adjustable 0–100% progress slider per note
- **Status management** — Pending, Completed, and Overdue states, auto-synced with due date/time
- **Favorites** — mark important notes for quick access
- **Search & filter** — search by title/description, filter by All, Favorites, Pending, Completed, Overdue, or Recent
- **Sorting** — sort notes by date or title
- **Scheduled reminders** — local push notifications fire before a note's due time, with a configurable lead time
- **Real-time sync** — powered by Cloud Firestore
- **Share app** — share the app with others directly from the menu
- **Stat dashboard** — live counts for Total, Done, and Overdue notes

##  Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter |
| Backend / Database | Firebase Cloud Firestore |
| Local Notifications | `flutter_local_notifications` |
| Timezone Handling | `timezone`, `flutter_timezone` |
| Sharing | `share_plus` |
| Language | Dart |

##  Core Modules

- `notification_service.dart` — handles notification initialization, instant notifications, and exact-alarm scheduled reminders with timezone awareness
- `notes_screen.dart` — main dashboard with search, filters, sorting, and stat capsules
- `add_edit_note_screen.dart` — create/edit form with date & time pickers, progress slider, and status management
- `firestore_service.dart` — Firestore CRUD operations for notes
- `note_model.dart` — data model for a note

##  Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Set up a Firebase project and add your `google-services.json` (Android) to `android/app/`
4. Ensure the following are present in `android/app/src/main/AndroidManifest.xml` **inside** the `<application>` tag:
   ```xml
   <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
   <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
       <intent-filter>
           <action android:name="android.intent.action.BOOT_COMPLETED"/>
       </intent-filter>
   </receiver>
   ```
5. Run `flutter clean` followed by `flutter run` (a fresh install is required after any manifest change)
6. On devices with aggressive battery management (e.g. ColorOS/Realme/Oppo/OnePlus), enable **auto-start** and **unrestricted background activity** for the app to ensure scheduled reminders fire reliably

##  About the Developer

**Jannatul**
Flutter Developer

-  Email: [jannatul.aip@gmail.com](mailto:jannatul.aip@gmail.com)
-  Portfolio: [jannat93.github.io/portfolio_flutter](https://jannat93.github.io/portfolio_flutter/)
-  CV: [View CV](https://drive.google.com/file/d/1iydH6lJ5FLZNbvZVkroHuhyxasHKH38m/view?usp=sharing)

##  License

This project is available for personal and educational use. Please reach out via email for any collaboration or usage inquiries.
