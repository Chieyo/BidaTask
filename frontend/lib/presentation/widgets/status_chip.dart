import 'package:flutter/material.dart';
import '../../../domain/enums/task_status.dart';

class StatusChip extends StatelessWidget {
  final TaskStatus status;
  
  const StatusChip({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Color(0xFF4CAF50); 
      case TaskStatus.inProgress:
        return const Color(0xFF2196F3); 
      case TaskStatus.cancelled:
        return const Color(0xFFF44336);
      case TaskStatus.notStarted:
        return const Color(0xFFFF9800);
    }
  }
}
