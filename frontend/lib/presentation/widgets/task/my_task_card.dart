import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/task_model.dart';

class MyTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onMarkDone;
  final VoidCallback? onConfirmCompletion;
  final VoidCallback? onDelete;

  const MyTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    this.onMarkDone,
    this.onConfirmCompletion,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isDueToday = task.dueDate != null && 
        task.dueDate!.year == now.year &&
        task.dueDate!.month == now.month &&
        task.dueDate!.day == now.day;
    
    final isDueTomorrow = !isDueToday && 
        task.dueDate != null &&
        task.dueDate!.difference(now).inDays == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Mark as Done button in one row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Expanded(
                  child: Text(
                    task.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Action buttons - only show one relevant button
                if (onMarkDone != null)
                  OutlinedButton(
                    onPressed: onMarkDone,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Mark as Done',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  )
                else if (onConfirmCompletion != null)
                  OutlinedButton(
                    onPressed: onConfirmCompletion,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      side: BorderSide(color: Colors.green[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Confirm Completion',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[800],
                      ),
                    ),
                  )
                else if (onDelete != null)
                  OutlinedButton(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      side: BorderSide(color: Colors.red[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
              ],
            ),
            
            // Author or Assignee
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                task.isTaken && task.assigneeName != null 
                    ? 'Taken by ${task.assigneeName}'
                    : 'by ${task.postedBy}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: task.isTaken ? Colors.green[600] : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Status and Due Date row
            Row(
              children: [
                // Task Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: task.isCompleted 
                        ? Colors.green[50]
                        : task.isPendingCompletion
                            ? Colors.orange[50]
                            : Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    task.isCompleted 
                        ? 'Completed'
                        : task.isPendingCompletion
                            ? 'Pending Completion'
                            : 'In Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: task.isCompleted 
                          ? Colors.green[700]
                          : task.isPendingCompletion
                              ? Colors.orange[700]
                              : Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Due Date
                if (task.dueDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDueToday ? Colors.red[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: isDueToday ? Colors.red[700] : Colors.grey[700],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          isDueToday 
                              ? 'Due Today!'
                              : isDueTomorrow 
                                  ? 'Due Tomorrow' 
                                  : 'Due in ${task.dueDate!.difference(now).inDays + 1}d',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: isDueToday ? Colors.red[700] : Colors.grey[700],
                            fontWeight: isDueToday ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
