import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const ReBoxApp());
}

class ReBoxApp extends StatelessWidget {
  const ReBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReBox - Donasi Barang Bekas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFF00736D),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00736D)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
