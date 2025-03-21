import 'package:flutter/material.dart';
import 'package:projectlavage/screens/Aidepage.dart';
import 'package:projectlavage/screens/ForgotPasswordPage.dart';
import 'package:provider/provider.dart';
import 'package:projectlavage/screens/AboutUsScreen.dart';
import 'package:projectlavage/screens/EditProfilePage.dart';
import 'package:projectlavage/screens/MyHomePage.dart';
import 'package:projectlavage/screens/ProfileScreen.dart';
import 'package:projectlavage/screens/signin_screen.dart';
import 'package:projectlavage/screens/signup_screen.dart';
import 'package:projectlavage/screens/user_screen.dart';

import 'ThemeProvider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Authentication',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode:
          themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MyHomePage(
            isDarkMode: themeProvider.isDarkMode,
            toggleTheme: themeProvider.toggleTheme,
          ),
          routes: {
            '/signup': (context) => SignUpScreen(
              isDarkMode: themeProvider.isDarkMode,
              toggleTheme: themeProvider.toggleTheme,
            ),
            '/signin': (context) => SignInScreen(
              isDarkMode: themeProvider.isDarkMode,
              toggleTheme: themeProvider.toggleTheme,
            ),
            '/aboutus': (context) => AboutUsScreen(
              isDarkMode: themeProvider.isDarkMode,
              toggleTheme: themeProvider.toggleTheme,
            ),
            '/help': (context) => Aidepage(

            ),
            '/profile': (context) => ProfileScreen(),
            '/edit_profile': (context) => EditProfilePage(
              isDarkMode: true, // ou false selon l'état
              toggleTheme: () {
                // action pour basculer le thème
              },
            ),


            '/home': (context) => UserScreen(
              username: '',
              isDarkMode: themeProvider.isDarkMode,
              toggleTheme: themeProvider.toggleTheme,
            ),
            '/forgot_password': (context) => ForgotPasswordPage(
              isDarkMode: themeProvider.isDarkMode,
              toggleTheme: themeProvider.toggleTheme,
            ),
          },
        );
      },
    );
  }
}
