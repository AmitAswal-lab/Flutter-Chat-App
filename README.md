Flutter Chat App
A modern, real-time chat application built with Flutter and Firebase. This project features a complete authentication workflow, one-on-one private messaging, a global chat room, and a clean, tab-based navigation system.
Features Implemented
Firebase Backend: Core functionality is powered by Firebase (Authentication, Cloud Firestore, and Storage).
User Authentication: Full sign-up (with profile picture upload), log-in, and log-out functionality using Firebase Authentication.
Real-time One-on-One Messaging: Users can search for other registered users and start private, real-time conversations.
Global Chat Room: A public chat room, accessible to all logged-in users, integrated seamlessly into the main screen.
Tabbed Navigation: A modern BottomNavigationBar allows users to easily switch between their private conversation list and the global chat.
Efficient & Scalable Database: A well-designed Firestore structure that separates chats into individual documents and message subcollections, allowing the app to scale.
Case-Insensitive User Search: Robust user search functionality that correctly finds users regardless of capitalization.
Polished UI: A dynamic UI that includes custom chat bubbles, message grouping for consecutive messages from the same user, and clear loading/empty states.
Input Validation: Robust, industry-standard validation for email and password fields.
Project Structure
The project is organized to separate concerns, making it clean and scalable.
code
Code
lib/
├── logic/
│   └── validator_logic.dart      # Reusable validation functions
├── screens/
│   ├── auth.dart                 # The authentication screen UI and logic
│   ├── chat.dart                 # The screen for displaying a single chat (private or global)
│   ├── conversations.dart        # The main screen with tabbed navigation
│   ├── private_chat.dart         # The widget for displaying the list of private chats
│   ├── user_search.dart          # The user search screen and logic
│   └── splash.dart               # The splash/loading screen
├── theme/
│   └── ... (theme files)
├── widgets/
│   ├── chat_bubble.dart          # The UI for a single message bubble
│   ├── chat_messages.dart        # Fetches and displays the list of messages for a chat
│   ├── new_message.dart          # The text input field for sending a message
│   └── user_image_picker.dart    # Widget for picking a user profile image
└── main.dart                     # App entry point and authentication state router
How It Was Built: The Development Journey
Project Initialization & Auth UI: A new Flutter project was created, and the initial UI for the Authentication Screen was built with a custom dark theme.
Firebase Setup & Integration: A Firebase project was created and linked to the app using the FlutterFire CLI.
Authentication Logic: firebase_auth was used to implement sign-up and log-in logic, including robust error handling for FirebaseAuthExceptions.
State Management & Routing: The core routing logic was built in main.dart using a StreamBuilder listening to authStateChanges() to automatically switch between the SplashScreen, AuthScreen, and the main app screen.
Refactoring for One-on-One Chat: The initial global chat was refactored into a scalable one-on-one system. This involved a major Firestore database redesign, creating a chats collection where each document holds the participants and a messages subcollection.
Building the Conversations List: The ConversationsScreen was created to display a list of a user's private chats by querying the chats collection for documents where their UID is in the participants array. A Firestore Composite Index was created to allow filtering and sorting by lastMessageTimestamp.
Implementing User Search: The UserSearchScreen was built to query the users collection. A case-insensitive search was achieved by creating and querying a dedicated lowercase username field, which required its own Firestore Index. The logic to create a new chat room document on the fly was also implemented here.
Adding the Global Chat Tab: The ConversationsScreen was converted into a StatefulWidget with a BottomNavigationBar to manage two tabs. The powerful ChatScreen widget was reused for the global chat by passing it a hardcoded chatRoomId ("global_chat"), demonstrating component reusability.
Getting Started
To run this project locally, follow these steps:
Prerequisites:
Flutter SDK installed.
A code editor like VS Code or Android Studio.
1. Clone the repository:
code
Sh
git clone <your-repository-url>
cd <your-project-directory>
2. Install dependencies:
code
Sh
flutter pub get
3. Setup Firebase:
Go to the Firebase Console and create a new project.
Follow the instructions to install the FlutterFire CLI: dart pub global activate flutterfire_cli.
Run flutterfire configure in your project's root directory and select the Firebase project you created. This will generate your unique lib/firebase_options.dart file.
In the Firebase Console, go to Authentication -> Sign-in method and enable the Email/Password provider.
Go to Cloud Firestore and create a database.
Go to Storage and create a storage bucket.
4. Run the application:
code
Sh
flutter run