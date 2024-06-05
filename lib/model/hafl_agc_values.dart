class HalfAgcValues {
  final String? timeStamp;
  final String? PDNUM;
  final int? gainType;

  final double? ledNum1;
  final double? ledNum2;
  final double? ledNum3;
  final double? ledNum4;
  final double? ledNum5;
  final double? ledNum6;


  HalfAgcValues({
    this.timeStamp,
    this.PDNUM,
    this.gainType,
    this.ledNum1,
    this.ledNum2,
    this.ledNum3,
    this.ledNum4,
    this.ledNum5,
    this.ledNum6,
  });

  Map<String, dynamic> toMap() => {
    'timeStamp': timeStamp,
    'PDNUM': PDNUM,
    'gainType': gainType,
    'ledNum1': ledNum1,
    'ledNum2': ledNum2,
    'ledNum3': ledNum3,
    'ledNum4': ledNum4,
    'ledNum5': ledNum5,
    'ledNum6': ledNum6,
  };
}