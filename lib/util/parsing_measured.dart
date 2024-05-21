import 'package:animal_case_study/model/measure_values.dart';
import 'package:animal_case_study/util/database_util.dart';

void parsingMeasured(String mTimeStamp, int bat, double temp, double accX, double accY, double accZ, double gyrX, double gyrY, double gyrZ, String comment, int volume, String power, List<String> tjMsg) async {

  final model = DatabaseUtil();
  model.database;

  List<String> split;

  double? LED1_PD5, LED1_PD6, LED1_PD7, LED1_PD8, LED1_PD9, LED1_PD10,
  LED2_PD5, LED2_PD6, LED2_PD7, LED2_PD8, LED2_PD9, LED2_PD10,
  LED3_PD5, LED3_PD6, LED3_PD7, LED3_PD8, LED3_PD9, LED3_PD10,
  LED4_PD5, LED4_PD6, LED4_PD7, LED4_PD8, LED4_PD9, LED4_PD10,
  LED5_PD5, LED5_PD6, LED5_PD7, LED5_PD8, LED5_PD9, LED5_PD10,
  LED6_PD5, LED6_PD6, LED6_PD7, LED6_PD8, LED6_PD9, LED6_PD10,

  LED7_PD6, LED7_PD5, LED7_PD4, LED7_PD3, LED7_PD2, LED7_PD1,
  LED8_PD6, LED8_PD5, LED8_PD4, LED8_PD3, LED8_PD2, LED8_PD1,
  LED9_PD6, LED9_PD5, LED9_PD4, LED9_PD3, LED9_PD2, LED9_PD1,
  LED10_PD6, LED10_PD5, LED10_PD4, LED10_PD3, LED10_PD2, LED10_PD1,
  LED11_PD6, LED11_PD5, LED11_PD4, LED11_PD3, LED11_PD2, LED11_PD1,
  LED12_PD6, LED12_PD5, LED12_PD4, LED12_PD3, LED12_PD2, LED12_PD1,

  LED13_PD15, LED13_PD16, LED13_PD17, LED13_PD18, LED13_PD19, LED13_PD20,
  LED14_PD15, LED14_PD16, LED14_PD17, LED14_PD18, LED14_PD19, LED14_PD20,
  LED15_PD15, LED15_PD16, LED15_PD17, LED15_PD18, LED15_PD19, LED15_PD20,
  LED16_PD15, LED16_PD16, LED16_PD17, LED16_PD18, LED16_PD19, LED16_PD20,
  LED17_PD15, LED17_PD16, LED17_PD17, LED17_PD18, LED17_PD19, LED17_PD20,
  LED18_PD15, LED18_PD16, LED18_PD17, LED18_PD18, LED18_PD19, LED18_PD20,

  LED19_PD16, LED19_PD15, LED19_PD14, LED19_PD13, LED19_PD12, LED19_PD11,
  LED20_PD16, LED20_PD15, LED20_PD14, LED20_PD13, LED20_PD12, LED20_PD11,
  LED21_PD16, LED21_PD15, LED21_PD14, LED21_PD13, LED21_PD12, LED21_PD11,
  LED22_PD16, LED22_PD15, LED22_PD14, LED22_PD13, LED22_PD12, LED22_PD11,
  LED23_PD16, LED23_PD15, LED23_PD14, LED23_PD13, LED23_PD12, LED23_PD11,
  LED24_PD16, LED24_PD15, LED24_PD14, LED24_PD13, LED24_PD12, LED24_PD11;

  print("[ParsingMeasured] mTimeStamp: $mTimeStamp");
  print("[ParsingMeasured] bat: $bat");
  print("[ParsingMeasured] temperature: $temp");

  print("[ParsingMeasured] accX: $accX");
  print("[ParsingMeasured] accY: $accY");
  print("[ParsingMeasured] accZ: $accZ");

  print("[ParsingMeasured] gyrX: $gyrX");
  print("[ParsingMeasured] gyrY: $gyrY");
  print("[ParsingMeasured] gyrZ: $gyrZ");

  print("[ParsingMeasured] comment: $comment");
  print("[ParsingMeasured] volume: $volume");

  print("[ParsingMeasured] power: $power");

  // TODO: tjMsg string 으로 바꿔서 => Tj# 부분 삭제 => 각각의 변수에 넣기
  for(var x in tjMsg){
    split = x.split(",");
    if (split[0] == "Ti1") {
      LED1_PD5 = double.parse(split[1].trim()) / 8.0;
      LED1_PD6 = double.parse(split[2].trim()) / 8.0;
      LED1_PD7 = double.parse(split[3].trim()) / 8.0;
      LED1_PD8 = double.parse(split[4].trim()) / 8.0;
      LED1_PD9 = double.parse(split[5].trim()) / 8.0;
      LED1_PD10 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti2") {
      LED2_PD5 = double.parse(split[1].trim()) / 8.0;
      LED2_PD6 = double.parse(split[2].trim()) / 8.0;
      LED2_PD7 = double.parse(split[3].trim()) / 8.0;
      LED2_PD8 = double.parse(split[4].trim()) / 8.0;
      LED2_PD9 = double.parse(split[5].trim()) / 8.0;
      LED2_PD10 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti3") {
      LED3_PD5 = double.parse(split[1].trim()) / 8.0;
      LED3_PD6 = double.parse(split[2].trim()) / 8.0;
      LED3_PD7 = double.parse(split[3].trim()) / 8.0;
      LED3_PD8 = double.parse(split[4].trim()) / 8.0;
      LED3_PD9 = double.parse(split[5].trim()) / 8.0;
      LED3_PD10 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti4") {
      LED4_PD5 = double.parse(split[1].trim()) / 8.0;
      LED4_PD6 = double.parse(split[2].trim()) / 8.0;
      LED4_PD7 = double.parse(split[3].trim()) / 8.0;
      LED4_PD8 = double.parse(split[4].trim()) / 8.0;
      LED4_PD9 = double.parse(split[5].trim()) / 8.0;
      LED4_PD10 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti5") {
      LED5_PD5 = double.parse(split[1].trim()) / 8.0;
      LED5_PD6 = double.parse(split[2].trim()) / 8.0;
      LED5_PD7 = double.parse(split[3].trim()) / 8.0;
      LED5_PD8 = double.parse(split[4].trim()) / 8.0;
      LED5_PD9 = double.parse(split[5].trim()) / 8.0;
      LED5_PD10 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti6") {
      LED6_PD5 = double.parse(split[1].trim()) / 8.0;
      LED6_PD6 = double.parse(split[2].trim()) / 8.0;
      LED6_PD7 = double.parse(split[3].trim()) / 8.0;
      LED6_PD8 = double.parse(split[4].trim()) / 8.0;
      LED6_PD9 = double.parse(split[5].trim()) / 8.0;
      LED6_PD10 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti7") {
      LED7_PD6 = double.parse(split[1].trim()) / 8.0;
      LED7_PD5 = double.parse(split[2].trim()) / 8.0;
      LED7_PD4 = double.parse(split[3].trim()) / 8.0;
      LED7_PD3 = double.parse(split[4].trim()) / 8.0;
      LED7_PD2 = double.parse(split[5].trim()) / 8.0;
      LED7_PD1 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti8") {
      LED8_PD6 = double.parse(split[1].trim()) / 8.0;
      LED8_PD5 = double.parse(split[2].trim()) / 8.0;
      LED8_PD4 = double.parse(split[3].trim()) / 8.0;
      LED8_PD3 = double.parse(split[4].trim()) / 8.0;
      LED8_PD2 = double.parse(split[5].trim()) / 8.0;
      LED8_PD1 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti9") {
      LED9_PD6 = double.parse(split[1].trim()) / 8.0;
      LED9_PD5 = double.parse(split[2].trim()) / 8.0;
      LED9_PD4 = double.parse(split[3].trim()) / 8.0;
      LED9_PD3 = double.parse(split[4].trim()) / 8.0;
      LED9_PD2 = double.parse(split[5].trim()) / 8.0;
      LED9_PD1 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti10") {
      LED10_PD6 = double.parse(split[1].trim()) / 8.0;
      LED10_PD5 = double.parse(split[2].trim()) / 8.0;
      LED10_PD4 = double.parse(split[3].trim()) / 8.0;
      LED10_PD3 = double.parse(split[4].trim()) / 8.0;
      LED10_PD2 = double.parse(split[5].trim()) / 8.0;
      LED10_PD1 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti11") {
      LED11_PD6 = double.parse(split[1].trim()) / 8.0;
      LED11_PD5 = double.parse(split[2].trim()) / 8.0;
      LED11_PD4 = double.parse(split[3].trim()) / 8.0;
      LED11_PD3 = double.parse(split[4].trim()) / 8.0;
      LED11_PD2 = double.parse(split[5].trim()) / 8.0;
      LED11_PD1 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti12") {
      LED12_PD6 = double.parse(split[1].trim()) / 8.0;
      LED12_PD5 = double.parse(split[2].trim()) / 8.0;
      LED12_PD4 = double.parse(split[3].trim()) / 8.0;
      LED12_PD3 = double.parse(split[4].trim()) / 8.0;
      LED12_PD2 = double.parse(split[5].trim()) / 8.0;
      LED12_PD1 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti13") {
      LED13_PD15 = double.parse(split[1].trim()) / 8.0;
      LED13_PD16 = double.parse(split[2].trim()) / 8.0;
      LED13_PD17 = double.parse(split[3].trim()) / 8.0;
      LED13_PD18 = double.parse(split[4].trim()) / 8.0;
      LED13_PD19 = double.parse(split[5].trim()) / 8.0;
      LED13_PD20 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti14") {
      LED14_PD15 = double.parse(split[1].trim()) / 8.0;
      LED14_PD16 = double.parse(split[2].trim()) / 8.0;
      LED14_PD17 = double.parse(split[3].trim()) / 8.0;
      LED14_PD18 = double.parse(split[4].trim()) / 8.0;
      LED14_PD19 = double.parse(split[5].trim()) / 8.0;
      LED14_PD20 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti15") {
      LED15_PD15 = double.parse(split[1].trim()) / 8.0;
      LED15_PD16 = double.parse(split[2].trim()) / 8.0;
      LED15_PD17 = double.parse(split[3].trim()) / 8.0;
      LED15_PD18 = double.parse(split[4].trim()) / 8.0;
      LED15_PD19 = double.parse(split[5].trim()) / 8.0;
      LED15_PD20 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti16") {
      LED16_PD15 = double.parse(split[1].trim()) / 8.0;
      LED16_PD16 = double.parse(split[2].trim()) / 8.0;
      LED16_PD17 = double.parse(split[3].trim()) / 8.0;
      LED16_PD18 = double.parse(split[4].trim()) / 8.0;
      LED16_PD19 = double.parse(split[5].trim()) / 8.0;
      LED16_PD20 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti17") {
      LED17_PD15 = double.parse(split[1].trim()) / 8.0;
      LED17_PD16 = double.parse(split[2].trim()) / 8.0;
      LED17_PD17 = double.parse(split[3].trim()) / 8.0;
      LED17_PD18 = double.parse(split[4].trim()) / 8.0;
      LED17_PD19 = double.parse(split[5].trim()) / 8.0;
      LED17_PD20 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti18") {
      LED18_PD15 = double.parse(split[1].trim()) / 8.0;
      LED18_PD16 = double.parse(split[2].trim()) / 8.0;
      LED18_PD17 = double.parse(split[3].trim()) / 8.0;
      LED18_PD18 = double.parse(split[4].trim()) / 8.0;
      LED18_PD19 = double.parse(split[5].trim()) / 8.0;
      LED18_PD20 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti19") {
      LED19_PD16 = double.parse(split[1].trim()) / 8.0;
      LED19_PD15 = double.parse(split[2].trim()) / 8.0;
      LED19_PD14 = double.parse(split[3].trim()) / 8.0;
      LED19_PD13 = double.parse(split[4].trim()) / 8.0;
      LED19_PD12 = double.parse(split[5].trim()) / 8.0;
      LED19_PD11 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti20") {
      LED20_PD16 = double.parse(split[1].trim()) / 8.0;
      LED20_PD15 = double.parse(split[2].trim()) / 8.0;
      LED20_PD14 = double.parse(split[3].trim()) / 8.0;
      LED20_PD13 = double.parse(split[4].trim()) / 8.0;
      LED20_PD12 = double.parse(split[5].trim()) / 8.0;
      LED20_PD11 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti21") {
      LED21_PD16 = double.parse(split[1].trim()) / 8.0;
      LED21_PD15 = double.parse(split[2].trim()) / 8.0;
      LED21_PD14 = double.parse(split[3].trim()) / 8.0;
      LED21_PD13 = double.parse(split[4].trim()) / 8.0;
      LED21_PD12 = double.parse(split[5].trim()) / 8.0;
      LED21_PD11 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti22") {
      LED22_PD16 = double.parse(split[1].trim()) / 8.0;
      LED22_PD15 = double.parse(split[2].trim()) / 8.0;
      LED22_PD14 = double.parse(split[3].trim()) / 8.0;
      LED22_PD13 = double.parse(split[4].trim()) / 8.0;
      LED22_PD12 = double.parse(split[5].trim()) / 8.0;
      LED22_PD11 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti23") {
      LED23_PD16 = double.parse(split[1].trim()) / 8.0;
      LED23_PD15 = double.parse(split[2].trim()) / 8.0;
      LED23_PD14 = double.parse(split[3].trim()) / 8.0;
      LED23_PD13 = double.parse(split[4].trim()) / 8.0;
      LED23_PD12 = double.parse(split[5].trim()) / 8.0;
      LED23_PD11 = double.parse(split[6].trim()) / 8.0;
    }

    if (split[0] == "Ti24") {
      LED24_PD16 = double.parse(split[1].trim()) / 8.0;
      LED24_PD15 = double.parse(split[2].trim()) / 8.0;
      LED24_PD14 = double.parse(split[3].trim()) / 8.0;
      LED24_PD13 = double.parse(split[4].trim()) / 8.0;
      LED24_PD12 = double.parse(split[5].trim()) / 8.0;
      LED24_PD11 = double.parse(split[6].trim()) / 8.0;
    }

  }

  await model.insertingMeasured(MeasuredValues(
    mTimeStamp: mTimeStamp,
    bat: bat,
    temp: temp,
    acc_x: accX,
    acc_y: accY,
    acc_z: accZ,
    gyr_x: gyrX,
    gyr_y: gyrY,
    gyr_z: gyrZ,
    comment: comment,
    volume: volume,
    power: power,

    LED1_PD5: LED1_PD5,
    LED1_PD6: LED1_PD6,
    LED1_PD7: LED1_PD7,
    LED1_PD8: LED1_PD8,
    LED1_PD9: LED1_PD9,
    LED1_PD10: LED1_PD10,

    LED2_PD5: LED2_PD5,
    LED2_PD6: LED2_PD6,
    LED2_PD7: LED2_PD7,
    LED2_PD8: LED2_PD8,
    LED2_PD9: LED2_PD9,
    LED2_PD10: LED2_PD10,

    LED3_PD5: LED3_PD5,
    LED3_PD6: LED3_PD6,
    LED3_PD7: LED3_PD7,
    LED3_PD8: LED3_PD8,
    LED3_PD9: LED3_PD9,
    LED3_PD10: LED3_PD10,

    LED4_PD5: LED4_PD5,
    LED4_PD6: LED4_PD6,
    LED4_PD7: LED4_PD7,
    LED4_PD8: LED4_PD8,
    LED4_PD9: LED4_PD9,
    LED4_PD10: LED4_PD10,

    LED5_PD5: LED5_PD5,
    LED5_PD6: LED5_PD6,
    LED5_PD7: LED5_PD7,
    LED5_PD8: LED5_PD8,
    LED5_PD9: LED5_PD9,
    LED5_PD10: LED5_PD10,

    LED6_PD5: LED6_PD5,
    LED6_PD6: LED6_PD6,
    LED6_PD7: LED6_PD7,
    LED6_PD8: LED6_PD8,
    LED6_PD9: LED6_PD9,
    LED6_PD10: LED6_PD10,

    LED7_PD6: LED7_PD6,
    LED7_PD5: LED7_PD5,
    LED7_PD4: LED7_PD4,
    LED7_PD3: LED7_PD3,
    LED7_PD2: LED7_PD2,
    LED7_PD1: LED7_PD1,

    LED8_PD6: LED8_PD6,
    LED8_PD5: LED8_PD5,
    LED8_PD4: LED8_PD4,
    LED8_PD3: LED8_PD3,
    LED8_PD2: LED8_PD2,
    LED8_PD1: LED8_PD1,

    LED9_PD6: LED9_PD6,
    LED9_PD5: LED9_PD5,
    LED9_PD4: LED9_PD4,
    LED9_PD3: LED9_PD3,
    LED9_PD2: LED9_PD2,
    LED9_PD1: LED9_PD1,

    LED10_PD6: LED10_PD6,
    LED10_PD5: LED10_PD5,
    LED10_PD4: LED10_PD4,
    LED10_PD3: LED10_PD3,
    LED10_PD2: LED10_PD2,
    LED10_PD1: LED10_PD1,

    LED11_PD6: LED11_PD6,
    LED11_PD5: LED11_PD5,
    LED11_PD4: LED11_PD4,
    LED11_PD3: LED11_PD3,
    LED11_PD2: LED11_PD2,
    LED11_PD1: LED11_PD1,

    LED12_PD6: LED12_PD6,
    LED12_PD5: LED12_PD5,
    LED12_PD4: LED12_PD4,
    LED12_PD3: LED12_PD3,
    LED12_PD2: LED12_PD2,
    LED12_PD1: LED12_PD1,

    LED13_PD15: LED13_PD15,
    LED13_PD16: LED13_PD16,
    LED13_PD17: LED13_PD17,
    LED13_PD18: LED13_PD18,
    LED13_PD19: LED13_PD19,
    LED13_PD20: LED13_PD20,

    LED14_PD15: LED14_PD15,
    LED14_PD16: LED14_PD16,
    LED14_PD17: LED14_PD17,
    LED14_PD18: LED14_PD18,
    LED14_PD19: LED14_PD19,
    LED14_PD20: LED14_PD20,

    LED15_PD15: LED15_PD15,
    LED15_PD16: LED15_PD16,
    LED15_PD17: LED15_PD17,
    LED15_PD18: LED15_PD18,
    LED15_PD19: LED15_PD19,
    LED15_PD20: LED15_PD20,

    LED16_PD15:  LED16_PD15,
    LED16_PD16: LED16_PD16,
    LED16_PD17: LED16_PD17,
    LED16_PD18: LED16_PD18,
    LED16_PD19: LED16_PD19,
    LED16_PD20: LED16_PD20,

    LED17_PD15: LED17_PD15,
    LED17_PD16: LED17_PD16,
    LED17_PD17: LED17_PD17,
    LED17_PD18: LED17_PD18,
    LED17_PD19: LED17_PD19,
    LED17_PD20: LED17_PD20,

    LED18_PD15: LED18_PD15,
    LED18_PD16: LED18_PD16,
    LED18_PD17: LED18_PD17,
    LED18_PD18: LED18_PD18,
    LED18_PD19: LED18_PD19,
    LED18_PD20: LED18_PD20,

    LED19_PD16: LED19_PD16,
    LED19_PD15: LED19_PD15,
    LED19_PD14: LED19_PD14,
    LED19_PD13: LED19_PD13,
    LED19_PD12: LED19_PD12,
    LED19_PD11: LED19_PD11,

    LED20_PD16: LED20_PD16,
    LED20_PD15: LED20_PD15,
    LED20_PD14: LED20_PD14,
    LED20_PD13: LED20_PD13,
    LED20_PD12: LED20_PD12,
    LED20_PD11: LED20_PD11,

    LED21_PD16: LED21_PD16,
    LED21_PD15: LED21_PD15,
    LED21_PD14: LED21_PD14,
    LED21_PD13: LED21_PD13,
    LED21_PD12: LED21_PD12,
    LED21_PD11: LED21_PD11,

    LED22_PD16: LED22_PD16,
    LED22_PD15: LED22_PD15,
    LED22_PD14: LED22_PD14,
    LED22_PD13: LED22_PD13,
    LED22_PD12: LED22_PD12,
    LED22_PD11: LED22_PD11,

    LED23_PD16: LED23_PD16,
    LED23_PD15: LED23_PD15,
    LED23_PD14: LED23_PD14,
    LED23_PD13: LED23_PD13,
    LED23_PD12: LED23_PD12,
    LED23_PD11: LED23_PD11,

    LED24_PD16: LED24_PD16,
    LED24_PD15: LED24_PD15,
    LED24_PD14: LED24_PD14,
    LED24_PD13: LED24_PD13,
    LED24_PD12: LED24_PD12,
    LED24_PD11: LED24_PD11,

  ));

}