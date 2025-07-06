import 'package:intl/intl.dart';

class DateFormatter {
  static String formatOrderTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    // If it's today, show time
    if (dateTime.year == now.year && 
        dateTime.month == now.month && 
        dateTime.day == now.day) {
      return DateFormat('h:mm a').format(dateTime);
    }
    
    // If it's yesterday
    if (dateTime.year == now.year && 
        dateTime.month == now.month && 
        dateTime.day == now.day - 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
    }
    
    // If it's within the last 7 days
    if (difference.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(dateTime);
    }
    
    // Otherwise show date and time
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }
  
  static String truncateAddress(String address, {int maxLength = 25}) {
    if (address.length <= maxLength) {
      return address;
    }
    return '${address.substring(0, maxLength - 3)}...';
  }
} 