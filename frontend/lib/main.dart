import 'package:flutter/material.dart';
import 'presentation/screens/task_manager_screen.dart';

void main() {
  runApp(const BidaTaskApp());
}

class BidaTaskApp extends StatelessWidget {
  const BidaTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BidaTask',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B67CA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TaskManagerScreen(),
    );
  }
}
