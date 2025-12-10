import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  MyApp({super.key, ApiService? apiService})
      : apiService = apiService ?? ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Thu Chi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeScreen(apiService: apiService),
    );
  }
}