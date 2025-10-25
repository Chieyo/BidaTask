import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../domain/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final LatLng? currentUserLocation;

  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.currentUserLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 140,
                width: double.infinity,
                color: Colors.grey[200],
                child: task.imageUrl != null
                    ? Image.network(
                        task.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.work_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
              ),
            ),
            
            // Task Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.formattedPrice,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category and Time
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.category_outlined,
                        text: task.category,
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        icon: Icons.access_time,
                        text: task.timeAgo,
                        theme: theme,
                      ),
                      if (task.isMyTask) ...[
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.person_outline,
                          text: 'Your Task',
                          theme: theme,
                          isHighlighted: true,
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location and Distance
                  if (currentUserLocation != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.getDistanceFrom(currentUserLocation!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  // Description (truncated)
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required ThemeData theme,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? theme.primaryColor.withOpacity(0.1) 
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHighlighted ? theme.primaryColor : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isHighlighted ? theme.primaryColor : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Example usage in a ListView:
class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final LatLng? currentLocation;
  
  const TaskList({
    Key? key,
    required this.tasks,
    this.currentLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          currentUserLocation: currentLocation,
          onTap: () {
            // Handle task tap
            // Navigator.push(...);
          },
        );
      },
    );
  }
}
