import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/task_model.dart';
import '../../widgets/background/animated_background.dart';
import '../../widgets/task/task_near_you_card.dart';

class AllTasksScreen extends StatefulWidget {
  final List<Task> tasks;
  
  const AllTasksScreen({super.key, required this.tasks});

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  String _activeCategory = 'All';
  
  List<Task> get _filteredTasks {
    return widget.tasks.where((task) {
      return _activeCategory == 'All' || 
             task.category.toLowerCase() == _activeCategory.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Shopping', 'Delivery', 'Chores', 'Misc'];
    
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Tasks Near You',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            // Category Chips
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _activeCategory == categories[index];
                  return GestureDetector(
                    onTap: () => setState(() => _activeCategory = categories[index]),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFD700) : const Color.fromRGBO(255, 255, 255, 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: Colors.white30),
                      ),
                      child: Center(
                        child: Text(
                          categories[index],
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.black87 : Colors.white,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Tasks Grid
            Expanded(
              child: _filteredTasks.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'No tasks found',
                          style: GoogleFonts.poppins(
                            color: const Color.fromRGBO(255, 255, 255, 0.7),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
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
            ),
          ],
        ),
      ),
    );
  }
}
