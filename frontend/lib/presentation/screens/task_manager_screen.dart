import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/task_model.dart';
import '../../services/task_service.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/task/my_task_card.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({Key? key}) : super(key: key);

  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TaskService _taskService = TaskService();
  List<Task> _activeTasks = [];
  List<Task> _postedTasks = [];
  List<Task> _completedTasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load active tasks and posted tasks, then try completed tasks separately
      try {
        final [activeTasks, postedTasks] = await Future.wait([
          _taskService.fetchMyTasks(),
          _taskService.fetchPostedTasks(),
        ]);

        final activeTaskList = (activeTasks as List<Task>?) ?? [];
        final postedTaskList = (postedTasks as List<Task>?) ?? [];
        
        // Try to load completed tasks separately
        List<Task> completedTasks = [];
        try {
          final completedResult = await _taskService.getCompletedTasks();
          if (completedResult['success'] == true) {
            completedTasks = (completedResult['tasks'] as List<dynamic>?)?.map((t) => Task.fromJson(t)).toList() ?? [];
          }
        } catch (e) {
          print('Error loading completed tasks: $e');
          // Continue without completed tasks if there's an error
        }

        if (mounted) {
          setState(() {
            _activeTasks = activeTaskList;
            _postedTasks = postedTaskList;
            _completedTasks = completedTasks;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error in task manager loading: $e');
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load tasks. Please try again. Error: $e';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load tasks. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshTasks() {
    _loadTasks();
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Posted by: ${task.postedBy}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (task.isTaken && task.assigneeName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Taken by: ${task.assigneeName}',
                style: TextStyle(color: Colors.green[600]),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Description: ${task.description}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Text(
              'Due: ${_formatDate(task.dueDate)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              'Price: \$${task.price.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No due date';
    return '${_getMonthAbbreviation(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonthAbbreviation(int month) {
    return const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][month - 1];
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => MyTaskCard(
        task: tasks[index],
        onTap: () => _showTaskDetails(tasks[index]),
        // In task manager, we don't show action buttons - it's just for viewing
        onMarkDone: null,
        onConfirmCompletion: null,
        onDelete: null,
      ),
    );
  }

  int _selectedIndex = 0;
  final List<String> _tabs = ['Today', 'Upcoming', 'Completed'];

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    final allTasks = _activeTasks; // Only show tasks the user has taken
    final now = DateTime.now();
    
    // Filter tasks for each tab
    final todayTasks = allTasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate = task.dueDate!;
      return dueDate.day == now.day &&
             dueDate.month == now.month &&
             dueDate.year == now.year;
    }).toList();
    
    final upcomingTasks = allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.isAfter(now);
    }).toList();
    
    final completedTasks = _completedTasks;

    return AnimatedBackground(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'My Tasks',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, size: 26, color: Colors.white),
              onPressed: _refreshTasks,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(30),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: _selectedIndex == index 
                            ? Colors.white 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: _selectedIndex == index
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        _tabs[index],
                        style: GoogleFonts.poppins(
                          color: _selectedIndex == index 
                              ? const Color(0xFF1E88E5) 
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: _buildTaskList(
            _selectedIndex == 0 
                ? todayTasks 
                : _selectedIndex == 1 
                    ? upcomingTasks 
                    : completedTasks
          ),
        ),
      ),
    );
  }
}
