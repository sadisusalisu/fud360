import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fud360/providers/auth_provider.dart';
import 'package:fud360/providers/donation_provider.dart';
import 'package:fud360/screens/splash_screen.dart';
import 'package:fud360/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DonationProvider()),
      ],
      child: MaterialApp(
        title: 'Fud360',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
