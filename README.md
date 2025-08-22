Flutter Chat App-

A modern, real-time chat application built with Flutter and Firebase. This project features a complete authentication workflow.

Features Implemented-

Firebase Backend: Core functionality is powered by Firebase.
User Authentication: Full sign-up, log-in, and log-out functionality using Firebase Authentication (Email & Password).
Input Validation: Robust, industry-standard validation for email and password fields to ensure data quality.
Dynamic UI: The app displays different screens based on the user's real-time authentication state.

Project Structure-
The project is organized to separate concerns, making it clean and scalable.
code
Code
lib/
├── logic/
│   └── validator_logic.dart    # Contains reusable validation functions
├── screens/
│   ├── auth.dart               # The authentication screen UI and logic
│   ├── chat.dart               # Placeholder screen for authenticated users
│   └── splash.dart             # The splash/loading screen
├── theme/
│   └── theme.dart              # Centralized ThemeData for the app
└── main.dart                   # App entry point and authentication state router


How It Was Built: The Development Journey-

This section outlines the step-by-step process followed to build the current version of the application.

1. Project Initialization & UI Scaffolding
A new Flutter project was created.
The initial UI for the Authentication Screen (screens/auth.dart) was built, containing text fields for email and password, a primary action button (Log in / Sign up), and a secondary button to toggle between the two modes.
A custom, modern dark theme was established in theme/theme.dart to control the app's appearance, including colors, button styles, and text field decorations.
2. Firebase Setup & Integration
A new project was created on the Firebase Console.
The FlutterFire CLI was installed and used to connect the Flutter app to the Firebase project.
The flutterfire configure command was run to automatically generate the firebase_options.dart configuration file.
Firebase was initialized in main.dart before the app starts to ensure all services are ready.
3. Authentication Logic
The firebase_auth package was added to the project dependencies.
Input validation logic was created in logic/validator_logic.dart for email and password fields, using regular expressions for robustness.
In screens/auth.dart, the _submit function was implemented to:
Trigger form validation.
Call createUserWithEmailAndPassword for sign-up.
Call signInWithEmailAndPassword for log-in.
Include try...catch blocks to gracefully handle FirebaseAuthException errors (like 'email-already-in-use' or 'wrong-password') and display them to the user in a SnackBar.
4. State Management & Routing
A placeholder ChatScreen and SplashScreen were created.
The core routing logic was implemented in main.dart using a StreamBuilder.
The StreamBuilder listens to FirebaseAuth.instance.authStateChanges(), which automatically emits a new state whenever a user logs in or out.
Based on the stream's snapshot, the app decides which screen to show:
ConnectionState.waiting: Show the SplashScreen.
snapshot.hasData: A user is logged in, show the ChatScreen.
snapshot has no data: No user is logged in, show the AuthScreen.
A sign-out button was added to the ChatScreen's AppBar to call FirebaseAuth.instance.signOut(), which automatically triggers the StreamBuilder to navigate back to the AuthScreen.
Getting Started
To run this project locally, follow these steps:
Prerequisites:
Flutter SDK installed.
A code editor like VS Code or Android Studio.
Clone the repository:
code
Sh
git clone <your-repository-url>
cd <your-project-directory>
Install dependencies:
code
Sh
flutter pub get
Setup Firebase:
Go to the Firebase Console and create a new project.
Follow the instructions to install the FlutterFire CLI: dart pub global activate flutterfire_cli.
Run flutterfire configure in your project's root directory and select the Firebase project you created. This will generate your unique lib/firebase_options.dart file.
In the Firebase Console, go to Authentication -> Sign-in method and enable the Email/Password provider.
Run the application:
code
Sh
flutter run