import 'package:flutter/material.dart';
import 'package:bidatask/presentation/pages/task_details_page.dart';
import 'package:bidatask/domain/entities/task.dart';
import 'package:bidatask/domain/repositories/task_repository.dart';

class DemoTaskRepository implements TaskRepository {
  @override
  Future<Task?> getTaskById(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return Task(
      id: taskId,
      title: 'Search for Book Binding Service',
      description:
          'Looking for someone who can help me search for an affordable book binding service, preferably one with good reviews and student rates. Please make sure it is within budget which is ₱ 500 per bind.',
      category: 'General Assistance',
      isUrgent: true,
      location: 'Lerma St., Brgy. Lerma, Naga City, 4400 Camarines Sur',
      imageUrls: [],
      reward: 500.0,
      userId: 'user_123',
      userName: 'Etheria Marie M. Bubong',
      userAvatar: null,
      userTier: 5,
      dueDate: DateTime.now().add(const Duration(days: 3)),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Details with Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Geist',
      ),
      home: TaskDetailsPage(
        taskId: 'demo_task_1',
        taskRepository: DemoTaskRepository(),
      ),
    );
  }
}
