import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/event_provider.dart';
import 'providers/registration_provider.dart';
import 'providers/category_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Event Management',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: Colors.white,
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: AppColors.primary,
                secondary: AppColors.primaryLight,
              ),
            ),
            home: const SplashScreen(), // Changed to SplashScreen
          );
        },
      ),
    );
  }
}
