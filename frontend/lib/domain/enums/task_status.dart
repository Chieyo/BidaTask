enum TaskStatus { notStarted, inProgress, completed, cancelled }

String getStatusText(TaskStatus status) {
  switch (status) {
    case TaskStatus.completed:
      return 'Completed';
    case TaskStatus.inProgress:
      return 'In Progress';
    case TaskStatus.cancelled:
      return 'Cancelled';
    case TaskStatus.notStarted:
    default:
      return 'Pending';
  }
}
