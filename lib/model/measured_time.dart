
class MeasuredTime {
  final String timeStamp;
  final int volume;
  final String comment;
  final int gainType;

  MeasuredTime({
    required this.timeStamp,
    required this.volume,
    required this.comment,
    required this.gainType
  });

  Map<String, dynamic> toMap() => {
    'mTimeStamp' : timeStamp,
    'volume' : volume,
    'comment' : comment,
    'gainType' : gainType
  };
}