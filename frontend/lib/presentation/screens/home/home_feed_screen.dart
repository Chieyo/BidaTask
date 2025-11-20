import 'package:flutter/material.dart';
import '../../widgets/user/user_greeting.dart';
import '../../widgets/background/animated_background.dart';
import '../../../domain/models/task_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/task/my_task_card.dart';
import '../../widgets/task/task_near_you_card.dart';
import '../tasks/all_tasks_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _activeCategory = 'All';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,  // Make scaffold transparent
        appBar: AppBar(
          backgroundColor: Colors.transparent,  // Transparent app bar
          elevation: 0,
          title: const UserGreeting(
            username: 'JM The Best',
            trustTier: '1',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs for Active/Posted Tasks
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[400],
              indicatorColor: const Color(0xFFFFD700),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Active Tasks'),
                Tab(text: 'Posted Tasks'),
              ],
            ),
          ),
          
          // Tab content for Active/Posted Tasks
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserTasksList(_userActiveTasks, 'No active tasks yet'),
                _buildUserTasksList(_userPostedTasks, 'No posted tasks yet'),
              ],
            ),
          ),
          
          // Tasks Near You Section
          _buildTasksNearYouSection(),
          const SizedBox(height: 24), // Add space at the bottom
        ],
      ),
    );
  }


  Widget _buildTasksNearYouSection() {
    final categories = ['All', 'Shopping', 'Delivery', 'Chores', 'Misc'];
    final filteredTasks = _getFilteredTasks();
    
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with See All button
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tasks Near You',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllTasksScreen(tasks: _nearbyTasks),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Category chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = _activeCategory == categories[index];
                return GestureDetector(
                  onTap: () => setState(() => _activeCategory = categories[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      categories[index],
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.black87 : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Tasks Grid with bottom spacing
          const SizedBox(height: 12),
          if (filteredTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24), // Added bottom margin
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No tasks found',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85, // Adjusted for better proportions
                crossAxisSpacing: 6,    // Reduced spacing between cards
                mainAxisSpacing: 6,     // Reduced vertical spacing
                mainAxisExtent: 165,    // Fixed height for each card
              ),
              itemCount: filteredTasks.length > 4 ? 4 : filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return TaskNearYouCard(
                  task: task,
                  onTap: () {
                    // Handle task tap
                    debugPrint('Tapped on task: ${task.title}');
                  },
                  onTakeTask: () {
                    // Handle take task
                    debugPrint('Take task: ${task.title}');
                  },
                );
              },
            ),
          
        ],
      ),
    );
  }
  
  List<Task> _getFilteredTasks() {
    if (_activeCategory == 'All') return _nearbyTasks;
    
    return _nearbyTasks.where((task) {
      return task.category.toLowerCase() == _activeCategory.toLowerCase();
    }).toList();
  }
  
  Widget _buildUserTasksList(List<Task> tasks, String emptyMessage) {
    if (tasks.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            emptyMessage,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: MyTaskCard(
            task: task,
            onTap: () {
              // Handle task tap
            },
            onMarkDone: () {
              // Handle mark as done
            },
          ),
        );
      },
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No tasks found',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskNearYouCard(
          task: tasks[index],
          onTap: () {
            // Handle task tap
          },
          onTakeTask: () {
            // Handle take task
          },
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              // Map
              Navigator.pushNamed(context, '/map');
            }
            else if (index == 2) {
              // New Task (golden + icon)
              Navigator.pushNamed(context, '/create-task');
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E88E5),
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 26),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined, size: 26),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700), // Gold color
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x80FFD700),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.black87, size: 28),
              ),
              label: 'New Task',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline, size: 26),
              label: 'Tasks',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 26),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // User's active tasks (tasks the user is working on)
  final List<Task> _userActiveTasks = [
    Task(
      id: 'active1',
      title: 'Grocery Shopping',
      description: 'Weekly grocery shopping and delivery',
      price: 1200.0,
      postedTime: DateTime.now().subtract(const Duration(hours: 2)),
      dueDate: DateTime.now().add(const Duration(days: 1)),
      location: '123 Green Meadows, Quezon City',
      postedBy: 'Maria S.',
      isMyTask: true,
      isUrgent: true,
      category: 'Shopping',
    ),
    Task(
      id: 'active2',
      title: 'Laptop Screen Repair',
      description: 'Replace broken screen on HP Pavilion',
      price: 3500.0,
      postedTime: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 3)),
      location: '456 Tech Hub, BGC',
      postedBy: 'John D.',
      isMyTask: true,
      isUrgent: false,
      category: 'Misc',
    ),
  ];

  // User's posted tasks (tasks the user created)
  final List<Task> _userPostedTasks = [
    Task(
      id: 'posted1',
      title: 'Furniture Assembly',
      description: 'Need help assembling IKEA furniture set',
      price: 1800.0,
      postedTime: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 2)),
      location: '789 Urban Living, Makati',
      postedBy: 'You',
      isUrgent: true,
      category: 'Chores',
    ),
    Task(
      id: 'posted2',
      title: 'Math Tutoring',
      description: 'Need help with college algebra',
      price: 800.0,
      postedTime: DateTime.now().subtract(const Duration(hours: 5)),
      dueDate: DateTime.now().add(const Duration(days: 3)),
      location: '321 Student Residences, Manila',
      postedBy: 'You',
      isUrgent: false,
      category: 'Misc',
    ),
  ];

  // Tasks near the user's location
  final List<Task> _nearbyTasks = [
    Task(
      id: 'delivery1',
      title: 'Lunch Delivery',
      description: 'Need someone to pick up and deliver lunch from a restaurant',
      price: 200.0,
      postedTime: DateTime.now().subtract(const Duration(minutes: 30)),
      dueDate: DateTime.now().add(const Duration(hours: 1)),
      location: '123 Food Street, Makati',
      postedBy: 'Hungry Office PH',
      isUrgent: true,
      category: 'Delivery',
    ),
    Task(
      id: 'delivery2',
      title: 'Document Courier',
      description: 'Need to deliver important documents to a client',
      price: 350.0,
      postedTime: DateTime.now().subtract(const Duration(hours: 2)),
      dueDate: DateTime.now().add(const Duration(hours: 4)),
      location: '456 Business Ave, BGC',
      postedBy: 'Legal Docs Inc.',
      isUrgent: false,
      category: 'Delivery',
    ),
    Task(
      id: 'near1',
      title: 'Pet Sitting',
      description: 'Need someone to walk my dog for a week',
      price: 1500.0,
      postedTime: DateTime.now().subtract(const Duration(hours: 2)),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      location: '123 Pet Lovers St, Taguig',
      postedBy: 'Sophia M.',
      isUrgent: false,
      category: 'Chores',
    ),
    Task(
      id: 'near2',
      title: 'Photo Editing',
      description: '50 product photos need white background',
      price: 2500.0,
      postedTime: DateTime.now().subtract(const Duration(hours: 5)),
      dueDate: DateTime.now().add(const Duration(days: 5)),
      location: '456 Digital Hub, Ortigas',
      postedBy: 'Creative Shop PH',
      isUrgent: true,
      category: 'Misc',
    ),
    Task(
      id: 'near3',
      title: 'Moving Assistance',
      description: 'Need help moving boxes to 3rd floor apartment',
      price: 2000.0,
      postedTime: DateTime.now().subtract(const Duration(hours: 2)),
      dueDate: DateTime.now().add(const Duration(days: 1)),
      location: '753 Moving St, Mandaluyong',
      postedBy: 'Miguel T.',
      isUrgent: true,
      category: 'Chores',
    ),
    Task(
      id: 'near4',
      title: 'IKEA Furniture Assembly',
      description: 'Need help assembling IKEA furniture (bed, desk, chair)',
      price: 1800.0,
      postedTime: DateTime.now().subtract(const Duration(hours: 1)),
      dueDate: DateTime.now().add(const Duration(days: 2)),
      location: '321 Urban Living, Makati',
      postedBy: 'James L.',
      isUrgent: true,
      category: 'Misc',
    ),
    Task(
      id: 'near5',
      title: 'Photo Editing',
      description: 'Need 50 product photos edited with white background',
      price: 2500.0,
      postedTime: DateTime.now().subtract(const Duration(hours: 12)),
      dueDate: DateTime.now().add(const Duration(days: 5)),
      location: '159 Digital Hub, Ortigas',
      postedBy: 'Creative Shop PH',
      isUrgent: false,
      category: 'Misc',
    ),
    Task(
      id: 'near6',
      title: 'Moving Assistance',
      description: 'Need help moving boxes to 3rd floor apartment (no elevator)',
      price: 2000.0,
      postedTime: DateTime.now().subtract(const Duration(hours: 2)),
      dueDate: DateTime.now().add(const Duration(days: 1)),
      location: '753 Moving St, Mandaluyong',
      postedBy: 'Miguel T.',
      isUrgent: true,
      category: 'Chores',
    ),
  ];
}