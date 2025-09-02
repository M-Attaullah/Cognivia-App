# 🧠 CogniVia – AI-Powered Cognitive Enhancement App

## 🚀 Project Overview

**CogniVia** is an intelligent cognitive enhancement application built with **Flutter** and **Firebase**, featuring AI-powered quizzes, intelligent task management, real-time community chat, and Google Mobile Ads integration. The app delivers a premium learning experience with Material Design 3 components, beautiful purple gradient themes, and seamless dark/light mode switching.

---

## 🌟 Features

- 🧠 **AI-Powered Smart Quizzes** - Intelligent quiz system with progress tracking and results analysis
- 📋 **Intelligent Task Management** - Professional task organizer with priority filtering and status tracking
- 💬 **Real-Time Community Chat** - Firebase-powered chat with WhatsApp-style message persistence
- 🎯 **Google Mobile Ads** - Integrated banner and interstitial ads for monetization
- 🎨 **Dynamic Purple Theming** - Beautiful gradient themes with professional dark/light mode toggle
- 🔐 **Firebase Authentication** - Secure email/password authentication system
- 📱 **Material Design 3** - Modern UI with professional purple headers and smooth animations
- 🏗️ **MVVM Architecture** - Clean, scalable code structure with Provider state management
- 🌐 **Cross-Platform** - Native performance on Android and iOS

---

## 📱 Screenshots

| Onboarding | Quiz Challenge | Task Manager | Community Chat |
|------------|----------------|--------------|----------------|
| ![Onboarding](screenshots/onboarding.png) | ![Quiz](screenshots/quiz.png) | ![Tasks](screenshots/tasks.png) | ![Chat](screenshots/chat.png) |

| Dark Theme | Purple Headers | Quiz Results | Banner Ads |
|------------|----------------|--------------|------------|
| ![Dark](screenshots/dark-theme.png) | ![Headers](screenshots/headers.png) | ![Results](screenshots/results.png) | ![Ads](screenshots/ads.png) |

---

## 📂 Project Structure
```
lib/
│
├── main.dart                          # Application entry point
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart             # Purple gradient color scheme
│   │   └── app_strings.dart            # App text constants
│   │
│   └── services/
│       └── ad_manager.dart             # Google Mobile Ads service
│
├── data/
│   ├── models/
│   │   ├── user_model.dart             # User data model
│   │   ├── task_model.dart             # Task data model
│   │   ├── quiz_model.dart             # Quiz data model
│   │   └── chat_model.dart             # Chat & message models
│   │
│   └── services/
│       ├── auth_service.dart           # Firebase authentication
│       ├── task_service.dart           # Task management service
│       ├── quiz_service.dart           # Quiz management service
│       └── chat_service.dart           # Real-time chat service
│
├── presentation/
│   ├── navigation/
│   │   └── main_navigation.dart        # Bottom navigation with theme toggle
│   │
│   ├── providers/
│   │   ├── auth_provider.dart          # Authentication state management
│   │   ├── task_provider.dart          # Task state management
│   │   ├── quiz_provider.dart          # Quiz state management
│   │   └── chat_provider.dart          # Chat state management
│   │
│   ├── screens/
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart  # Onboarding with banner ads
│   │   │
│   │   ├── auth/
│   │   │   ├── login_screen.dart       # Login with theme toggle
│   │   │   ├── signup_screen.dart      # Signup with theme toggle
│   │   │   └── profile_screen.dart     # User profile management
│   │   │
│   │   ├── home/
│   │   │   └── home_screen.dart        # Main dashboard
│   │   │
│   │   ├── quiz/
│   │   │   ├── quiz_screen.dart        # Quiz main screen with purple header
│   │   │   ├── quiz_play_screen.dart   # Interactive quiz gameplay
│   │   │   ├── quiz_result_screen.dart # Results with purple header
│   │   │   └── quiz_history_screen.dart# Quiz history tracking
│   │   │
│   │   ├── tasks/
│   │   │   ├── tasks_screen.dart       # Task manager with purple header
│   │   │   └── add_edit_task_screen.dart # Task creation/editing
│   │   │
│   │   └── chat/
│   │       ├── chat_screen.dart        # Community chat with purple header
│   │       └── chat_detail_screen.dart # Individual chat conversation
│   │
│   └── widgets/
│       └── common/
│           ├── cognivia_logo.dart      # App logo widget
│           ├── task_card.dart          # Professional task card
│           └── real_chat_tile.dart     # Chat tile widget
```

---

## 🧠 Skills Demonstrated

- 🏛️ **MVVM Architecture** - Clean separation with Model-View-ViewModel pattern
- 🔥 **Firebase Integration** - Authentication, Realtime Database for chat persistence
- 📊 **State Management** - Efficient Provider pattern with theme management
- 🎨 **Custom UI Design** - Material Design 3 with purple gradient themes
- 💰 **Ad Integration** - Google Mobile Ads with banner and interstitial ads
- 🔐 **Security** - Firebase authentication with secure data handling
- ⚡ **Performance** - Optimized list rendering and real-time updates
- 🧪 **Code Quality** - Maintainable, scalable, and well-documented codebase

---

## 🛠 Technologies Used

- **Flutter** (Dart) - Cross-platform mobile development framework
- **Firebase** - Authentication, Realtime Database for chat functionality
- **Google Mobile Ads** - Banner and interstitial ad monetization
- **Provider** - State management solution with theme handling
- **Material Design 3** - Modern UI components with purple gradient design

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.8.1 or higher)
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter plugin
- Firebase project setup
- Google AdMob account

### Installation
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Cognivia-App.git
   cd Cognivia-App
    ```
   
2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at Firebase Console
   - Enable Authentication with Email/Password provider
   - Enable Realtime Database with these rules:
     ```bash
     {
        "rules": {
          "chats": {
            ".read": "auth != null",
            ".write": "auth != null"
          },
          "chatMessages": {
            ".read": "auth != null",
            ".write": "auth != null"
          },
          "userChats": {
            ".read": "auth != null",
            ".write": "auth != null"
          }
        }
     }
     ```
  - Download and add  ```google-services.json ``` to  ```android/app/ ```
  - Download and add  ```GoogleService-Info.plist ``` to  ```ios/Runner/ ```

4. **Firebase Setup**
   - Create a new Firebase project at Firebase Console
   - Enable Authentication with Email/Password provider
   - Enable Realtime Database with these rules:
     ```bash
     {
        "rules": {
          "chats": {
            ".read": "auth != null",
            ".write": "auth != null"
          },
          "chatMessages": {
            ".read": "auth != null",
            ".write": "auth != null"
          },
          "userChats": {
            ".read": "auth != null",
            ".write": "auth != null"
          }
        }
     }
     ```
  - Download and add  ```google-services.json ``` to  ```android/app/ ```
  - Download and add  ```GoogleService-Info.plist ``` to  ```ios/Runner/ ```

       
4. **Run the app**
   ```bash
   flutter run
   ```

---


