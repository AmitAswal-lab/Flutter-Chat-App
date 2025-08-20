import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 0, 0, 0),
);

final theme = ThemeData.from(useMaterial3: true, colorScheme: colorScheme)
    .copyWith(

       textTheme: ThemeData().textTheme.apply(
    bodyColor: Colors.white,
       ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // A subtle tint of the primary color looks very modern
        fillColor: colorScheme.primary.withAlpha(13),

        // Define consistent borders for all states
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border in the default state
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // Use a very subtle color for the default border
          borderSide: BorderSide(color: colorScheme.surfaceContainerHigh),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // Use the primary color to indicate focus
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // Use the error color for validation failures
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // A thicker error border when the invalid field is focused
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),

        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),

        // Adds a bit more space inside the text field, making it feel less cramped
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colorScheme.primary),
          foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
       theme: theme, 
       home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (ctx, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const SplashScreen();
          }
          if(snapshot.hasData){
            return const ChatScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
