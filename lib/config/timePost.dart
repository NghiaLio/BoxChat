class Timepost {
  static String timeBefore(DateTime time){
    final DateTime timeNow = DateTime.now();
    Duration diff = timeNow.difference(time);
    if(diff.inHours < 24 && diff.inHours >=1){
      //show hour before 
      return '${diff.inHours}h before';
    }else if(diff.inHours < 1){
      //show minute before
      return '${diff.inMinutes}min before';
    }else if(diff.inDays >=1 && diff.inDays <=3){
      //show day before
      return '${diff.inDays} days before';
    }else{
      //show day 
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}