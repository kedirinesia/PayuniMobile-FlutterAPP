import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? onboardingSeen = prefs.getBool('onboardingSeen');


  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: onboardingSeen == true ? LoginScreen() : OnboardingScreen(),
  ));
}
