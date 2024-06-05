import 'dart:math';

import 'package:animal_case_study/model/hafl_agc_values.dart';

import '../model/agc_values.dart';
import 'database_util.dart';

void  ParsingHalfAGC(String getTimeStamp, List<String> gain, int getGainType) async{
  final model = DatabaseUtil();
  model.database;

  List<String> splitted;
  String? PDNUM;

  int index = 0;

  double? led1;
  double? led2;
  double? led3;
  double? led4;
  double? led5;
  double? led6;

  for(var x in gain){
    splitted = x.split(",");
    PDNUM = splitted[0].trim();
    // index = 2 ~ 25
    // led1 = double.parse(splitted[1]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[1]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble(); => dummy 값

    // splitted[2] = led1 // splitted[3] = led2 // splitted[4] = led3 // splitted[5] = led4 // splitted[6] = led5 // splitted[7] = led6 // splitted[8] = led7 // splitted[9] = led8
    // splitted[10] = led9 // splitted[11] = led10 // splitted[12] = led11 // splitted[13] = led12 // splitted[14] = led13 // splitted[15] = led14 // splitted[16] = led15
    // splitted[17] = led16 // splitted[18] = led17 // splitted[19] = led18 // splitted[20] = led19 // splitted[21] = led20 // splitted[22] = led21 // splitted[23] = led22
    // splitted[24] = led23 // splitted[25] = led24

    // PD가 1~6일 때
    // 중복 : 5,6,15,16
    if(splitted[0] == "Tagc-B1" || splitted[0] == "Tagc-B2" || splitted[0] == "Tagc-B3" || splitted[0] == "Tagc-B4") index = 8;
    if(splitted[0] == "Tagc-B7" || splitted[0] == "Tagc-B8" || splitted[0] == "Tagc-B9" || splitted[0] == "Tagc-B10") index = 2;
    if(splitted[0] == "Tagc-B11" || splitted[0] == "Tagc-B12" || splitted[0] == "Tagc-B13" || splitted[0] == "Tagc-B14" ) index = 20;
    if(splitted[0] == "Tagc-B17" || splitted[0] == "Tagc-B18" || splitted[0] == "Tagc-B19" || splitted[0] == "Tagc-B20") index = 14;

    // led 1~12 : total 12
    if(splitted[0] == "Tagc-B5" || splitted[0] == "Tagc-B6"){
      double? led1in;
      double? led2in;
      double? led3in;
      double? led4in;
      double? led5in;
      double? led6in;
      double? led7in;
      double? led8in;
      double? led9in;
      double? led10in;
      double? led11in;
      double? led12in;

      index = 2;

      led1in = double.parse(splitted[index]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led2in = double.parse(splitted[index+1]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+1]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led3in = double.parse(splitted[index+2]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+2]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led4in = double.parse(splitted[index+3]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+3]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led5in = double.parse(splitted[index+4]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+4]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led6in = double.parse(splitted[index+5]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+5]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();

      led7in = double.parse(splitted[index+6]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+6]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led8in = double.parse(splitted[index+7]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+7]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led9in = double.parse(splitted[index+8]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+8]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led10in = double.parse(splitted[index+9]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+9]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led11in = double.parse(splitted[index+10]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+10]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led12in = double.parse(splitted[index+11]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+11]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();

      await model.insertingHalfAgc(HalfAgcValues(
        timeStamp: getTimeStamp,
        PDNUM: "$PDNUM 1to6",
        gainType: getGainType,
        ledNum1: led1in,
        ledNum2: led2in,
        ledNum3: led3in,
        ledNum4: led4in,
        ledNum5: led5in,
        ledNum6: led6in,
      ));

      await model.insertingHalfAgc(HalfAgcValues(
        timeStamp: getTimeStamp,
        PDNUM: "$PDNUM 7to10",
        gainType: getGainType,
        ledNum1: led7in,
        ledNum2: led8in,
        ledNum3: led9in,
        ledNum4: led10in,
        ledNum5: led11in,
        ledNum6: led12in,
      ));
    }

    // led 13~24 : total 12
    if(splitted[0] == "Tagc-B15" || splitted[0] == "Tagc-B16"){
      double? led1in;
      double? led2in;
      double? led3in;
      double? led4in;
      double? led5in;
      double? led6in;
      double? led7in;
      double? led8in;
      double? led9in;
      double? led10in;
      double? led11in;
      double? led12in;

      index = 14;

      led1in = double.parse(splitted[index]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led2in = double.parse(splitted[index+1]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+1]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led3in = double.parse(splitted[index+2]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+2]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led4in = double.parse(splitted[index+3]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+3]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led5in = double.parse(splitted[index+4]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+4]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led6in = double.parse(splitted[index+5]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+5]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();

      led7in = double.parse(splitted[index+6]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+6]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led8in = double.parse(splitted[index+7]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+7]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led9in = double.parse(splitted[index+8]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+8]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led10in = double.parse(splitted[index+9]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+9]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led11in = double.parse(splitted[index+10]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+10]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led12in = double.parse(splitted[index+11]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+11]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();

      await model.insertingHalfAgc(HalfAgcValues(
        timeStamp: getTimeStamp,
        PDNUM: "$PDNUM 13to18",
        gainType: getGainType,
        ledNum1: led1in,
        ledNum2: led2in,
        ledNum3: led3in,
        ledNum4: led4in,
        ledNum5: led5in,
        ledNum6: led6in,
      ));

      await model.insertingHalfAgc(HalfAgcValues(
        timeStamp: getTimeStamp,
        PDNUM: "$PDNUM 19to24",
        gainType: getGainType,
        ledNum1: led7in,
        ledNum2: led8in,
        ledNum3: led9in,
        ledNum4: led10in,
        ledNum5: led11in,
        ledNum6: led12in,
      ));
    }

    // 5, 6, 15, 16일 때는 전체 다 이 순서를 ....

    if(splitted[0] != "Tagc-B5" && splitted[0] != "Tagc-B6" && splitted[0] != "Tagc-B15" && splitted[0] != "Tagc-B16"){
      led1 = double.parse(splitted[index]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led2 = double.parse(splitted[index+1]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+1]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led3 = double.parse(splitted[index+2]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+2]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led4 = double.parse(splitted[index+3]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+3]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led5 = double.parse(splitted[index+4]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+4]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
      led6 = double.parse(splitted[index+5]) == 0 ? 0 : (pow(10, (((((double.parse(splitted[index+5]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();

      await model.insertingHalfAgc(HalfAgcValues(
        timeStamp: getTimeStamp,
        PDNUM: PDNUM,
        gainType: getGainType,
        ledNum1: led1,
        ledNum2: led2,
        ledNum3: led3,
        ledNum4: led4,
        ledNum5: led5,
        ledNum6: led6,
      ));
    }
  }
}