import 'package:flutter/material.dart';
import 'core.dart';
import 'screens/auth.dart';

void main() => runApp(const CarRentalApp());

class CarRentalApp extends StatelessWidget {
  const CarRentalApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Car Rental',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const LoginScreen(),
      );
}
