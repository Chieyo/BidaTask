import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../domain/models/task_model.dart';
import '../widgets/task/task_card.dart';

class TaskFeedScreen extends StatefulWidget {
  const TaskFeedScreen({Key? key}) : super(key: key);

  @override
  State<TaskFeedScreen> createState() => _TaskFeedScreenState();
}

class _TaskFeedScreenState extends State<TaskFeedScreen> {
  late List<Task> _sampleTasks;

  @override
  void initState() {
    super.initState();
    _sampleTasks = [
      Task(
        id: '1',
        title: 'Help move furniture',
        description: 'Need help moving furniture to my new apartment on the 3rd floor. Will need help with a couch, bed, and some boxes.',
        price: 50.0,
        postedTime: DateTime(2025, 10, 25, 8, 30),
        location: const LatLng(14.5995, 120.9842), // Sample Manila coordinates
        postedBy: 'user123',
        category: 'Moving',
        isMyTask: true,
      ),
      Task(
        id: '2',
        title: 'Grocery shopping',
        description: 'Need someone to buy groceries for an elderly person. List will be provided.',
        price: 30.0,
        postedTime: DateTime(2025, 10, 24, 15, 45),
        location: const LatLng(14.6012, 120.9867),
        postedBy: 'user456',
        category: 'Shopping',
      ),
      Task(
        id: '3',
        title: 'Tutoring in Math',
        description: 'Looking for a math tutor for my high school son. Topics: Algebra and Geometry.',
        price: 40.0,
        postedTime: DateTime(2025, 10, 23, 10, 15),
        location: const LatLng(14.5980, 120.9820),
        postedBy: 'user789',
        category: 'Education',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Sample current user location (you'll replace this with actual location later)
    final currentLocation = const LatLng(14.6000, 120.9842);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Will implement filter functionality later
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _sampleTasks.length,
        itemBuilder: (context, index) {
          final task = _sampleTasks[index];
          return TaskCard(
            task: task,
            currentUserLocation: currentLocation,
            onTap: () {
              // Handle task tap
              _showTaskDetails(context, task);
            },
          );
        },
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted ${task.timeAgo} • ${task.getDistanceFrom(const LatLng(14.6000, 120.9842))}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(task.description),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle task acceptance
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task accepted!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Accept Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
