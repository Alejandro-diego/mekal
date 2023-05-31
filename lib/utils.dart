import 'package:intl/intl.dart';

class Utils {

  static String toDateTime(DateTime dateTime) {  
    
    
    final time = DateFormat.Hm('pt').format(dateTime);

    return time;
  }

  static String toDate(DateTime dateTime) {
    final date = DateFormat.yMMMMEEEEd('pt').format(dateTime);
    return date;
  }

  static String toTime(DateTime dateTime) {
    final time = DateFormat.Hm('pt').format(dateTime);
    return time;
  }
}
