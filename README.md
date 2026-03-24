# 📰 Chronicle — NYT News App

A modern, production-ready Flutter application that delivers top stories from the New York Times with a clean UI, smart caching, and powerful filtering.

---

## 🚀 Overview

**Chronicle** is a feature-rich Flutter application built with a strong focus on:

* Clean architecture
* Performance optimization
* Real-world UX handling (offline, caching, errors)

> This project is designed to demonstrate production-level thinking, not just assignment completion.

---

## ✨ Features

### 🏠 Home Screen

* Browse articles by categories:

  * Home, World, Arts, Science, Technology, Health, Travel, Food, Opinion
* Smooth scrolling & responsive layout
* Pull-to-refresh support
* Infinite scroll pagination

---

### 🔍 Search & Filters

* Search across:

  * Title
  * Description
  * Author
* Advanced filtering:

  * Author filter
  * Location filter (geo-based)
  * Sort by newest / oldest
* Active filter indicator

---

### 📄 Article Detail Screen

* Title, author, date, description, image
* Clean typography
* Open article in browser

---

### 🔖 Bookmarks

* Save articles locally
* Persistent storage using Hive
* Dedicated bookmarks screen

---

### 🌙 Dark Mode

* System-aware theme
* Manual toggle
* Fully adaptive UI

---

### 📶 Offline Support

* Detects connectivity status
* Displays cached articles when offline
* Graceful fallback UI

---

## ⚡ Architecture & Performance

### 🧠 Smart Caching

* Section-wise caching
* TTL-based invalidation
* Background refresh of stale data

---

### 🔄 Optimized API Handling

* Prevents redundant API calls
* Detects latest articles using ID comparison
* Handles:

  * Timeout
  * No internet
  * Rate limiting (429)

---

### 🧱 Clean Architecture

```
lib/
│
├── models/           # Data models
│   ├── article.dart
│   ├── article.g.dart      
│
├── services/         # API, cache, filtering logic
│   ├── news_service.dart
│   ├── cache_service.dart
│   └── filter_service.dart
│
├── providers/        # State management (Provider)
│   └── news_provider.dart
│
├── screens/          # UI screens
│   ├── article_detail_screen.dart
│   ├── bookmarks_screen.dart
│   └── home_screen.dart
│     
├── widgets/          # Reusable UI components
│   ├── article_card.dart
│   ├── filter_sheet.dart
│   └── shimmer_loader.dart
│
├── theme/            # App theme
│   └── app_theme.dart
│
```

---

### ⚙️ Tech Stack

* Flutter
* Provider (state management)
* Dio (network layer)
* Hive (local storage)
* Connectivity Plus (network detection)
* Cached Network Image
* Shimmer (loading UI)

---

## 🧪 Unit Testing

The project includes **unit tests focused on business logic validation** .

### ✅ Covered Areas

* Author filtering
* Location filtering
* Search functionality (with debounce handling)
* Sorting (newest & oldest)
* Filter clearing logic
* Bookmark toggling logic

### 🧠 Testing Approach

* Uses controlled mock data via `setArticlesForTest`
* Avoids dependency on API/network
* Ensures deterministic and fast tests
* Focuses on **core logic correctness**

### ▶️ Run Tests

```bash
flutter test test/news_provider_test.dart
```

---

## 🎁 Bonus Features Implemented

* ✅ Offline caching (Hive)
* ✅ Image caching
* ✅ Smooth animations
* ✅ Dark mode
* ✅ Unit testing
* ✅ Pagination
* ✅ Background refresh

---

## 🛠️ Setup Instructions

---

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/your-username/chronicle.git
cd chronicle
```

---

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

---

### 3️⃣ Add Environment Variables

Create a `.env` file:

```env
NYT_API_KEY=your_api_key_here
```

Get API key:
https://developer.nytimes.com/

---

## 🤖 Android Setup (IMPORTANT)

### Requirements

* Android Studio installed
* Android SDK configured
* Emulator or physical device

---

### Run on Android

```bash
flutter run
```

---

### If Gradle build fails

```bash
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

---

### If device not detected

```bash
flutter devices
adb devices
```

---

### Enable USB Debugging (Physical Device)

1. Go to **Settings → About Phone**
2. Tap **Build Number 7 times**
3. Enable **Developer Options**
4. Turn on **USB Debugging**

---

### Common Android Issues

| Issue            | Fix                                     |
| ---------------- | --------------------------------------- |
| Gradle error     | `flutter clean`                         |
| SDK missing      | Install via Android Studio              |
| Device not found | Enable USB debugging                    |
| Slow build       | Use emulator with hardware acceleration |

---

## 🍏 iOS Setup (Optional)

```bash
open ios/Runner.xcworkspace
```

* Set unique bundle ID
* Enable automatic signing
* Select Apple team

---

## 💡 Key Design Decisions

* Separation of concerns via service layer
* Provider used as controller (not overloaded)
* Caching-first approach for performance
* UX-first design (loading, error, offline)

---

## ⚠️ Notes

* Requires internet for initial fetch
* Uses cached data when offline
* Handles API limits gracefully

---

## 👨‍💻 Author

**Dev Raval**

---

## ⭐ Final Thoughts

This project demonstrates:

* Clean architecture
* Real-world problem solving
* Performance optimization
* Strong Flutter fundamentals

> Built with production-level thinking and attention to detail.
