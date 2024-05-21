

import 'dart:math';

import '../model/agc_values.dart';
import 'database_util.dart';

void  ParsingAGC(String getTimeStamp, List<String> gain) async{
  final model = DatabaseUtil();
  model.database;

  List<String> splitted;
  String? ledNum;
  double? led1;
  double? led2;
  double? led3;
  double? led4;
  double? led5;
  double? led6;
  double? led7;
  double? led8;
  double? led9;
  double? led10;
  double? led11;
  double? led12;
  double? led13;
  double? led14;
  double? led15;
  double? led16;
  double? led17;
  double? led18;
  double? led19;
  double? led20;
  double? led21;
  double? led22;
  double? led23;
  double? led24;
  double? led25;

  for(var x in gain){
    splitted = x.split(",");
    ledNum = splitted[0].trim();
    led1 = (pow(10, (((((double.parse(splitted[1]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led2 = (pow(10, (((((double.parse(splitted[2]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led3 = (pow(10, (((((double.parse(splitted[3]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led4 = (pow(10, (((((double.parse(splitted[4]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led5 = (pow(10, (((((double.parse(splitted[5]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led6 = (pow(10, (((((double.parse(splitted[6]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led7 = (pow(10, (((((double.parse(splitted[7]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led8 = (pow(10, (((((double.parse(splitted[8]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led9 = (pow(10, (((((double.parse(splitted[9]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led10 = (pow(10, (((((double.parse(splitted[10]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led11 = (pow(10, (((((double.parse(splitted[11]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led12 = (pow(10, (((((double.parse(splitted[12]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led13 = (pow(10, (((((double.parse(splitted[13]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led14 = (pow(10, (((((double.parse(splitted[14]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led15 = (pow(10, (((((double.parse(splitted[15]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led16 = (pow(10, (((((double.parse(splitted[16]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led17 = (pow(10, (((((double.parse(splitted[17]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led18 = (pow(10, (((((double.parse(splitted[18]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led19 = (pow(10, (((((double.parse(splitted[19]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led20 = (pow(10, (((((double.parse(splitted[20]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led21 = (pow(10, (((((double.parse(splitted[21]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led22 = (pow(10, (((((double.parse(splitted[22]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led23 = (pow(10, (((((double.parse(splitted[23]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led24 = (pow(10, (((((double.parse(splitted[24]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
    led25 = (pow(10, (((((double.parse(splitted[25]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();

    await model.insertingAGC(AgcValues(
      timeStamp: getTimeStamp,
      lednum: ledNum,
      led1: led1,
      led2: led2,
      led3: led3,
      led4: led4,
      led5: led5,
      led6: led6,
      led7: led7,
      led8: led8,
      led9: led9,
      led10: led10,
      led11: led11,
      led12: led12,
      led13: led13,
      led14: led14,
      led15: led15,
      led16: led16,
      led17: led17,
      led18: led18,
      led19: led19,
      led20: led20,
      led21: led21,
      led22: led22,
      led23: led23,
      led24: led24,
      led25: led25,
    ));

  }
}