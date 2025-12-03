import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/task.dart';
import '../../domain/enums/task_status.dart';
import '../widgets/task_item.dart';
import '../widgets/task_form.dart';
import '../widgets/background/animated_background.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({Key? key}) : super(key: key);

  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Task> _tasks = [];
  bool _showTaskForm = false;
  Task? _editingTask;
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

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // In a real app, this would be an API call
      final tasks = [
        Task(
          id: '1',
          title: 'Clean the garden',
          author: 'Ritual S',
          dueDate: DateTime.now().add(const Duration(hours: 1)),
          status: TaskStatus.inProgress,
          isPostedByMe: false,
          assignedTo: 'You',
          description: 'Task accepted by you. Due soon!',
        ),
        Task(
          id: '2',
          title: 'Take a photo',
          author: 'Dingding A',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          status: TaskStatus.inProgress,
          isPostedByMe: false,
          assignedTo: 'You',
          description: 'Task in progress. 2/5 photos completed.',
        ),
        Task(
          id: '3',
          title: 'Buy rose bouquet',
          author: 'Lover B',
          dueDate: DateTime.now().add(const Duration(days: 1, hours: 6)),
          status: TaskStatus.notStarted,
          isPostedByMe: true,
          description: 'Waiting for acceptance from team member.',
        ),
        Task(
          id: '4',
          title: 'Sort documents',
          author: 'Reantazo J',
          dueDate: DateTime.now().add(const Duration(days: 1, hours: 5)),
          status: TaskStatus.completed,
          isPostedByMe: true,
          assignedTo: 'You',
          description: 'Task marked as completed. Awaiting review.',
        ),
      ];

      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
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

  void _handleTaskUpdated(Task updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      } else {
        _tasks.add(updatedTask);
      }
      _showTaskForm = false;
      _editingTask = null;
    });
  }

  void _handleTaskDeleted(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
    });
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
              'Posted by: ${task.author}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (task.assignedTo != null) ...[
              const SizedBox(height: 8),
              Text(
                'Assigned to: ${task.assignedTo}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 16),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(task.description!), 
              const SizedBox(height: 16),
            ],
            Text(
              'Due: ${_formatDate(task.dueDate)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            if (task.status == TaskStatus.inProgress && !task.isPostedByMe)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _handleTaskUpdated(task.copyWith(status: TaskStatus.completed));
                    Navigator.pop(context);
                  },
                  child: const Text('Mark as Completed'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new task',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => TaskItem(
        task: tasks[index],
        onTap: () => _showTaskDetails(tasks[index]),
        onEdit: tasks[index].isPostedByMe ? () {
          setState(() {
            _editingTask = tasks[index];
            _showTaskForm = true;
          });
        } : null,
        onComplete: !tasks[index].isPostedByMe ? () {
          _handleTaskUpdated(tasks[index].copyWith(status: TaskStatus.completed));
        } : null,
        onCancel: tasks[index].isPostedByMe ? () {
          _showDeleteConfirmation(tasks[index].id);
        } : null,
      ),
    );
  }

  Future<void> _showDeleteConfirmation(String taskId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                _handleTaskDeleted(taskId);
                Navigator.of(context).pop();
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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
    final activeTasks = _tasks.where((task) => task.status != TaskStatus.completed).toList();
    final completedTasks = _tasks.where((task) => task.status == TaskStatus.completed).toList();
    final todayTasks = activeTasks.where((task) => 
      task.dueDate.day == DateTime.now().day &&
      task.dueDate.month == DateTime.now().month &&
      task.dueDate.year == DateTime.now().year
    ).toList();
    
    final upcomingTasks = activeTasks.where((task) => 
      task.dueDate.isAfter(DateTime.now().add(const Duration(days: 1)))
    ).toList();

    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

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
              icon: const Icon(Icons.search, size: 26, color: Colors.white),
              onPressed: () {},
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
        body: Stack(
          children: [
            _showTaskForm
                ? TaskForm(
                    initialTask: _editingTask,
                    onSubmit: _handleTaskUpdated,
                    onCancel: () => setState(() {
                      _showTaskForm = false;
                      _editingTask = null;
                    }),
                  )
                : Container(
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
            if (!_showTaskForm)
              Positioned(
                right: 24,
                bottom: 24,
                child: FloatingActionButton(
                  backgroundColor: const Color(0xFFFFD700),
                  elevation: 4,
                  onPressed: () {
                    setState(() {
                      _editingTask = null;
                      _showTaskForm = true;
                    });
                  },
                  child: const Icon(Icons.add, size: 32, color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
