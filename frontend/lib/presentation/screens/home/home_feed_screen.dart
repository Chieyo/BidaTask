import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/user/user_greeting.dart';
import '../../widgets/background/animated_background.dart';
import '../../../domain/models/task_model.dart';
import '../../widgets/task/my_task_card.dart';
import '../../widgets/task/task_near_you_card.dart';
import '../tasks/all_tasks_screen.dart';
import '../../../services/task_service.dart';
import '../../../services/auth_service.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _activeCategory = 'All';
  late TabController _tabController;
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();

  List<Task> _activeTasks = [];
  List<Task> _postedTasks = [];
  List<Task> _nearbyTasks = [];

  String _username = 'BidaTasker';
  String _trustTier = '1';

  bool _isLoadingPostedTasks = false;
  bool _isLoadingNearbyTasks = false;
  String? _postedTasksError;
  String? _nearbyTasksError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHomeFeedData();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await _authService.getProfile();
      if (response['success'] == true) {
        final user = response['user'] ?? {};
        final rawName = (user['full_name'] ?? user['fullName'] ?? user['username'] ?? '').toString().trim();
        final rawTier = (user['trustTier'] ?? user['trust_tier'] ?? '1').toString();

        if (!mounted) return;

        setState(() {
          _username = rawName.isEmpty ? 'BidaTasker' : rawName;
          _trustTier = rawTier.isEmpty ? '1' : rawTier;
        });
      }
    } catch (_) {
      // Silently keep defaults if profile fetch fails
    }
  }

  Future<void> _loadHomeFeedData() async {
    await Future.wait([
      _loadPostedTasks(),
      _loadNearbyTasks(),
    ]);
  }

  Future<void> _loadPostedTasks() async {
    setState(() {
      _isLoadingPostedTasks = true;
      _postedTasksError = null;
    });

    List<Task>? fetched;
    String? error;

    try {
      fetched = await _taskService.fetchMyTasks();
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      if (fetched != null) {
        _postedTasks = fetched;
      }
      _postedTasksError = error;
      _isLoadingPostedTasks = false;
    });
  }

  Future<void> _loadNearbyTasks() async {
    setState(() {
      _isLoadingNearbyTasks = true;
      _nearbyTasksError = null;
    });

    List<Task>? fetched;
    String? error;

    try {
      fetched = await _taskService.fetchNearbyTasks();
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      if (fetched != null) {
        _nearbyTasks = fetched;
      }
      _nearbyTasksError = error;
      _isLoadingNearbyTasks = false;
    });
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
          title: UserGreeting(
            username: _username,
            trustTier: _trustTier,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
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
                _buildUserTasksList(
                  _activeTasks,
                  'No active tasks yet',
                  isLoading: false,
                ),
                _buildUserTasksList(
                  _postedTasks,
                  'No posted tasks yet',
                  isLoading: _isLoadingPostedTasks,
                  errorMessage: _postedTasksError,
                  onRetry: _loadPostedTasks,
                ),
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
    final categories = [
      'All',
      'Delivery',
      'Shopping',
      'Household Chores',
      'Online Assistance',
      'General Assistance',
      'Personal',
      'Misc',
    ];
    
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
          if (_isLoadingNearbyTasks)
            _buildGlassMessageCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading tasks...',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            )
          else if (_nearbyTasksError != null)
            _buildGlassMessageCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No tasks near you right now',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try again in a bit or tap retry below.',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loadNearbyTasks,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFFD700),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (filteredTasks.isEmpty)
            _buildGlassMessageCard(
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
                    debugPrint('Tapped on task: ${task.title}');
                  },
                  onTakeTask: () {
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

  Widget _buildUserTasksList(
    List<Task> tasks,
    String emptyMessage, {
    bool isLoading = false,
    String? errorMessage,
    Future<void> Function()? onRetry,
  }) {
    if (isLoading) {
      return _buildStatusCard(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading tasks...',
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            )
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return _buildStatusCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emptyMessage,
              style: GoogleFonts.poppins(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We could not load this list. Please try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    if (tasks.isEmpty) {
      return _buildStatusCard(
        Center(
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

  Widget _buildStatusCard(Widget child) {
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
      child: child,
    );
  }

  Widget _buildGlassMessageCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
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
            } else if (index == 2) {
              // New Task (golden + icon)
              Navigator.pushNamed(context, '/create-task');
            } else if (index == 3) {
              // Tasks / Task Manager
              Navigator.pushNamed(context, '/task-manager');
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
}