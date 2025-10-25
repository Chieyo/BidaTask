import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import '../../widgets/user/user_greeting.dart';
import '../../../domain/models/task_model.dart';
import '../../widgets/task/task_card.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  _HomeFeedScreenState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _selectedIndex = 0;  // For bottom navigation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const UserGreeting(
          username: 'John',
          trustTier: '1',
        ),
        actions: [
          // Chat icon
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
            onPressed: () {
              // TODO: Navigate to chat
            },
          ),
          // Notification icon
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task summary cards will go here
          _buildTaskSummarySection(),
          const SizedBox(height: 24),
          
          // Tasks Near You section will go here
          _buildTasksNearYouSection(),
        ],
      ),
    );
  }

  // Placeholder for task summary section
  Widget _buildTaskSummarySection() {
    return Container(); // We'll implement this next
  }

  // Placeholder for tasks near you section
  Widget _buildTasksNearYouSection() {
    return Container(); // We'll implement this next
  }

  // Bottom navigation bar
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        // TODO: Handle navigation
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4CAF50), // Green color
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'New Task',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist_rtl_outlined),
          label: "To-Do's",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}