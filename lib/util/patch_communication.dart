import 'package:animal_case_study/util/ble_communication.dart';
import 'package:animal_case_study/util/ble_provider.dart';
import 'package:provider/provider.dart';

import 'global_variable_setting.dart';

class PatchCommunication{
  final context = GlobalVariableSetting.navigatorState.currentContext;
  BLECommunication ble = BLECommunication();
  String msg = "[ERR] get message failed";

  void initialSetting(){
    ble.listeningStart();

    /* TODO - initialSetting
        1. write st
        2. write sn
        3. write status1
        4. write sm0, 100
        5. write sl0, 5000
        6. write sk0, 8
        7+. LED Power setting
        7. write status0
    */

    msg = context!.watch<BLEProvider>().msg.last;

    int count = 0;

    ble.write("St");

    while(msg.contains("Return0")){
      if(msg.contains("Ready")) {
        count++; // 1
        ble.write("Sn");
        print("St => Return0 => Sn: count = $count");
      }

      if(msg.contains("Tn")){
        count++; // 2
        msg = msg.replaceAll(RegExp(r'[^0-9]'), "");
        double bat = double.parse(msg);
        batteryComputation(bat);
        ble.write("status1");
        print("Sn => Tn => status1: count = $count");
      }

      if(msg.contains("Return1")) {
        count++; // 3
        ble.write("Sm0, 100");
        print("Return1 => Tn => status1: count = $count");
      }
      if(msg.contains("Tm0")) {
        count++; // 4
        ble.write("Sl0, 5000");
      }
      if(msg.contains("Tl0")) {
        count++; // 5
        ble.write("Sk0, 8");
      }
      // TODO: LED power setting
      if(msg.contains("Tk0")) {
        count++; // 6
        ble.write("status0");
      }

      if(count > 6) break;
    }
  }

  void batteryComputation(double b){
    if(b >= 4000.0){
      context!.read<BLEProvider>().battery = 100;
    } else{
      b -= 3600.0;
      b /= 4.0;
      context!.read<BLEProvider>().battery = b.floor();
    }
  }

  void agcMeasure(){
    ble.write("agc");
  }

  void measuring(){
    List<String> measureMsg = context!.watch<BLEProvider>().msg;
    List<String> measurement = [];

    // TODO: 그 전에 배터리, 온도, imu 센서 값도 같이 저장 되도록
    ble.write("Sn");
    while(measureMsg.last.contains("Return1")){
      if(measureMsg.last.contains("Tn")) ble.write("So");
      if(measureMsg.last.contains("To")) ble.write("Sp");
      if(measureMsg.last.contains("Tp")) ble.write("status1");
    }

    int index = 1;
    ble.write("Sj");
    while(measurement.isNotEmpty && measurement.length % 24 == 0){
      if(measureMsg.last.contains("Tj$index")){
        measurement.add(measureMsg.last);
        index++;
      }
    }
  }
}