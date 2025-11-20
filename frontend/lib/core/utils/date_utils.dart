import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

String formatTime(DateTime time) {
  return DateFormat('h:mm a').format(time);
}

String formatDateTime(DateTime dateTime) {
  return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
}

bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && 
         date.month == now.month && 
         date.day == now.day;
}
