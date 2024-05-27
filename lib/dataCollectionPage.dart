import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:animal_case_study/util/ble_provider.dart';
import 'package:animal_case_study/util/parsing_agc.dart';
import 'package:animal_case_study/util/parsing_measured.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

class DataCollectionPage extends StatefulWidget {
  const DataCollectionPage({super.key});

  @override
  State<DataCollectionPage> createState() => _DataCollectionPageState();
}

enum PDTypes { power35, power20, power10, power5, initial}

class _DataCollectionPageState extends State<DataCollectionPage> {

  static const String rx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // write data to the rx characteristic to send it to the UART interface.
  static const String tx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // Enable notifications for the tx characteristic to receive data from the application.
  static const String suid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // nordic uart service uuid

  PDTypes? _types = PDTypes.initial;

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<List<int>> _lastValueSubscription;
  late BluetoothDevice device;
  late BluetoothService service;
  late List<BluetoothCharacteristic> characteristic;
  int? _rssi;
  int idxTx = 1;
  int idxRx = 0;

  List<String> msg = [];
  List<String> agcMsg = [];
  List<String> tjMsg = [];

  String comment = "";
  int volume = 0;

  int patchState = 0;
  double battery = 0.0;
  int batteryMeasure = 0;
  late double accX, accY, accZ, gyrX, gyrY, gyrZ;
  double temp = 0.0;

  bool initialization = false;

  String todayString = "";
  bool measuring = false;
  bool measuredAgc = false;
  bool ledPdSet = false;

  int aORm = 0;
  int countReboot = 0;
  int countMeasure = 0;

  List<String> measureLog = [];
  List<String> simpleMeasureLog = [];
  List<String> commentLog = [];
  List<String> volumeLog = [];
  List<int> adcMeasureCount = [0, 0, 0, 0, 0, 0];
  List<int> agcMeasureCount = [0, 0, 0];

  List<double> agcMeasurement = [];


  final ScrollController _scrollController = ScrollController();
  final volumeTextController = TextEditingController();
  final commentTextController = TextEditingController();
  final cmdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, (){
      if(kDebugMode){
        print("[AIScreen] !!Init state start!!");
        print("[AIScreen] patch state is $patchState");
      }

      todayString = DateFormat.yMMMd().format(DateTime.now());

      // device = context.read()<BLEProvider>().device;
      device = Provider.of<BLEProvider>(context, listen: false).device;
      print("device : ${device.platformName}");

      msg.clear();
      // msg.add("START!");

      _connectionStateSubscription = device.connectionState.listen((state) async {

        if(kDebugMode){
          print("[HomeScreen] initState() state: $state");
        }

        if(state == BluetoothConnectionState.disconnected){

        }
        if(state == BluetoothConnectionState.connected){
          if(kDebugMode){
            print("-------[HomeScreen] _connectionState listeningToChar()-------");
          }

          listeningToChar();

          write("St");
          if(kDebugMode){
            print("-------[HomeScreen] _connectionState listeningToChar() done-------");
          }
          if(kDebugMode){
            print("[AIScreen] _lastValueSubscription paused?: ${_lastValueSubscription.isPaused == true}");
          }
        }
        switch(state){
          case BluetoothConnectionState.connected : break;
          case BluetoothConnectionState.disconnected: break;
          default: break;
        }
        if (state == BluetoothConnectionState.connected && _rssi == null) {
          _rssi = await device.readRssi();
        }
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  void listeningToChar(){
    service = context.read<BLEProvider>().service;

    if(kDebugMode){
      print("[AIScreen] listeningToChar(): service uid is ${service.uuid.toString().toUpperCase()}");
    }
    characteristic = service.characteristics;
    if(kDebugMode){
      print("[AIScreen] listeningToChar(): first element of char is ${characteristic[0].uuid.toString().toUpperCase()}");
    }

    switch (characteristic.first.uuid.toString().toUpperCase()){
      case rx: idxTx = 1; idxRx = 0;
      if (kDebugMode) {
        print("rx = ${characteristic[idxRx].uuid.toString().toUpperCase()}\ntx = ${characteristic[idxTx].uuid.toString().toUpperCase()}");
      }
      break;
      case tx: idxTx = 0; idxRx = 1;
      if (kDebugMode) {
        print("rx = ${characteristic[idxRx].uuid.toString().toUpperCase()}\ntx = ${characteristic[idxTx].uuid.toString().toUpperCase()}");
      }
      break;
      default:
        if (kDebugMode) {
          print("characteristic doesn't match any");
        }
        Navigator.pop(context);
        break;
    }

    device.discoverServices();
    if(kDebugMode){
      print("[AIScreen] listeningToChar(): Before set notify value discover services");
    }

    _lastValueSubscription = characteristic[idxTx].lastValueStream.listen((value) async {
      String convertedStr = utf8.decode(value).trimRight();

      if(kDebugMode){
        print("[!!LastValueListen!!] listen string: $convertedStr");
      }

      checking(convertedStr);

      if (mounted) {
        setState(() {});
      }
    });

    device.cancelWhenDisconnected(_lastValueSubscription);

    characteristic[idxTx].setNotifyValue(true);

    if (kDebugMode) {
      print("tx = ${characteristic[idxTx].uuid.toString().toUpperCase()}\nset notify");
    }

  }

  void findService() async{
    print("Finding service");
    for(var x in await device.discoverServices()){
      if(x.uuid.toString().toUpperCase() == suid){
        service = x;
        storingService(x);
      }
    }
    print("service uuid: ${service.uuid}");
  }

  void storingService(BluetoothService s){
    context.read<BLEProvider>().service = s;
  }
  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _lastValueSubscription.cancel();
    super.dispose();
  }

  void checking(String msgString){
    if(kDebugMode){
      print("-------[AIScreen] checking start-------");
      print("[AIScreen] checking() current patch state: $patchState");
    }

    if(msgString != ""){
      msg.add(msgString);

      if(msgString.contains("Ready")){
        measuring = true;
        setState(() {
          patchState = 1;
        });

        write("Sn");

        if(kDebugMode){
          print("[AIScreen] checking() : patchState $patchState");
        }
      }

      if(patchState == 1 && msgString.contains("Tn")){
        if(kDebugMode){
          print("[AIScreen] checking() Tn: patchState $patchState");
        }
        String result = msg.last.replaceAll(RegExp(r'[^0-9]'), "");
        battery = double.parse(result);
        batteryMeasure = battery.floor();
        if(kDebugMode){
          print("Battery : $battery");
        }
        if(battery >= 4000.0){
          battery = 100.0;
        }else {
          battery -= 3600.0;
          battery /= 4.0;
        }

        if(kDebugMode){
          print("Battery : $battery");
        }

        setState(() {
          patchState = 2;
          if(kDebugMode){
            print("[AIScreen] checking()-Tn: patch state should be 2: $patchState");
          }
        });

        write("Sp");
      }

      if(patchState == 2 && msgString.contains("Tp")){
        msgString = msgString.replaceAll("Tp", "");
        setState(() {
          msgString = msgString.replaceAll("Tp", "");
          List<String> split;
          split = msgString.split(",");
          accX = double.parse(split[0].trim());
          accY = double.parse(split[1].trim());
          accZ = double.parse(split[2].trim());

          gyrX = double.parse(split[3].trim());
          gyrY = double.parse(split[4].trim());
          gyrZ = double.parse(split[5].trim());
        });
        if(!initialization){
          setState(() {
            patchState = 3;
          });
          write("status1");
        } else {
          setState(() {
            measuring = false;
            patchState = 0;
          });
        }

        if(aORm > 0){
          setState(() {
            patchState = 1;
            measuring = true;
          });
          write("status1");
        }
      }

      if(patchState == 3 && msgString.contains("Return1")){
        write("Sm0, 100");
        setState(() {
          patchState = 4;
        });
      }

      if(patchState == 4 && msgString.contains("Tm0")){
        write("Sl0, 5000");
        setState(() {
          patchState = 5;
        });
      }

      if(patchState == 5 && msgString.contains("Tl0")){
        write("Sk0, 8");
        setState(() {
          patchState = 0;
        });
        Future.delayed(const Duration(seconds: 1), (){
          write("status0");
        });
        measuring = false;
        initialization = true;
      }

      if(patchState == 1 && msgString.contains("Return1")){
        setState(() {
          patchState = 2;
        });
        if(aORm == 1){
          agcMsg.clear();
          write("agc");
        }
        if(aORm == 2) write("So"); // 온도 저장 후 => Si
        if(aORm == 3){
          switch(_types){
            case PDTypes.power35:
              setState(() {
                patchState = 3;
                measuring = true;
              });
              write("Sb1,5");
              break;
            case PDTypes.power20:
              setState(() {
                patchState = 4;
                measuring = true;
              });
              write("Sb1,12");
              break;
            case PDTypes.power10:
              setState(() {
                patchState = 5;
                measuring = true;
              });
              write("Sb1,25");
              break;
            case PDTypes.power5:
              setState(() {
                patchState = 6;
                measuring = true;
              });
              write("Sb1,52");
              break;
            default: break;
          }
        }
      }

      if(patchState == 3 && msgString.contains("Tb")){
        if(msgString == "Tb1") write("Sb2,4");
        if(msgString=="Tb2") write("Sb3,5");
        if(msgString=="Tb3") write("Sb4,5");
        if(msgString=="Tb4") write("Sb5,6");
        if(msgString=="Tb5") write("Sb6,6");
        if(msgString=="Tb6") write("Sb7,5");
        if(msgString=="Tb7") write("Sb8,2");
        if(msgString=="Tb8") write("Sb9,5");
        if(msgString=="Tb9") write("Sb10,6");
        if(msgString=="Tb10") write("Sb11,6");
        if(msgString=="Tb11") write("Sb12,6");
        if(msgString=="Tb12") write("Sb13,4");
        if(msgString=="Tb13") write("Sb14,4");
        if(msgString=="Tb14") write("Sb15,5");
        if(msgString=="Tb15") write("Sb16,5");
        if(msgString=="Tb16") write("Sb17,6");
        if(msgString=="Tb17") write("Sb18,6");
        if(msgString=="Tb18") write("Sb19,5");
        if(msgString=="Tb19") write("Sb20,4");
        if(msgString=="Tb20") write("Sb21,5");
        if(msgString=="Tb21") write("Sb22,5");
        if(msgString=="Tb22") write("Sb23,6");
        if(msgString=="Tb23") write("Sb24,6");
        if(msgString=="Tb24"){
          setState(() {
            aORm = 0;
            patchState = 0;
            measuring = false;
            ledPdSet = true;
          });
          write("status0");
        }
      }

      if(patchState == 4 && msgString.contains("Tb")){
        if(msgString=="Tb1") write("Sb2,12");
        if(msgString=="Tb2") write("Sb3,9");
        if(msgString=="Tb3") write("Sb4,10");
        if(msgString=="Tb4") write("Sb5,12");
        if(msgString=="Tb5") write("Sb6,11");
        if(msgString=="Tb6") write("Sb7,12");
        if(msgString=="Tb7") write("Sb8,12");
        if(msgString=="Tb8") write("Sb9,9");
        if(msgString=="Tb9") write("Sb10,10");
        if(msgString=="Tb10") write("Sb11,12");
        if(msgString=="Tb11") write("Sb12,11");
        if(msgString=="Tb12") write("Sb13,12");
        if(msgString=="Tb13") write("Sb14,12");
        if(msgString=="Tb14") write("Sb15,9");
        if(msgString=="Tb15") write("Sb16,10");
        if(msgString=="Tb16") write("Sb17,11");
        if(msgString=="Tb17") write("Sb18,11");
        if(msgString=="Tb18") write("Sb19,12");
        if(msgString=="Tb19") write("Sb20,12");
        if(msgString=="Tb20") write("Sb21,10");
        if(msgString=="Tb21") write("Sb22,10");
        if(msgString=="Tb22") write("Sb23,12");
        if(msgString=="Tb23") write("Sb24,12");
        if(msgString=="Tb24"){
          setState(() {
            aORm = 0;
            patchState = 0;
            measuring = false;
            ledPdSet = true;
          });
          write("status0");
        }
      }

      if(patchState == 5 && msgString.contains("Tb")){
        if(msgString=="Tb1") write("Sb2,25");
        if(msgString=="Tb2") write("Sb3,18");
        if(msgString=="Tb3") write("Sb4,19");
        if(msgString=="Tb4") write("Sb5,24");
        if(msgString=="Tb5") write("Sb6,24");
        if(msgString=="Tb6") write("Sb7,25");
        if(msgString=="Tb7") write("Sb8,25");
        if(msgString=="Tb8") write("Sb9,19");
        if(msgString=="Tb9") write("Sb10,20");
        if(msgString=="Tb10") write("Sb11,25");
        if(msgString=="Tb11") write("Sb12,23");
        if(msgString=="Tb12") write("Sb13,25");
        if(msgString=="Tb13") write("Sb14,25");
        if(msgString=="Tb14") write("Sb15,18");
        if(msgString=="Tb15") write("Sb16,19");
        if(msgString=="Tb16") write("Sb17,24");
        if(msgString=="Tb17") write("Sb18,24");
        if(msgString=="Tb18") write("Sb19,25");
        if(msgString=="Tb19") write("Sb20,25");
        if(msgString=="Tb20") write("Sb21,19");
        if(msgString=="Tb21") write("Sb22,20");
        if(msgString=="Tb22") write("Sb23,25");
        if(msgString=="Tb23") write("Sb24,24");
        if(msgString=="Tb24"){
          setState(() {
            aORm = 0;
            patchState = 0;
            measuring = false;
            ledPdSet = true;
          });
          write("status0");
        }
      }

      if(patchState == 6 && msgString.contains("Tb")){
        if(msgString=="Tb1") write("Sb2,52");
        if(msgString=="Tb2") write("Sb3,36");
        if(msgString=="Tb3") write("Sb4,38");
        if(msgString=="Tb4") write("Sb5,49");
        if(msgString=="Tb5") write("Sb6,48");
        if(msgString=="Tb6") write("Sb7,54");
        if(msgString=="Tb7") write("Sb8,52");
        if(msgString=="Tb8") write("Sb9,37");
        if(msgString=="Tb9") write("Sb10,39");
        if(msgString=="Tb10") write("Sb11,51");
        if(msgString=="Tb11") write("Sb12,47");
        if(msgString=="Tb12") write("Sb13,52");
        if(msgString=="Tb13") write("Sb14,52");
        if(msgString=="Tb14") write("Sb15,36");
        if(msgString=="Tb15") write("Sb16,38");
        if(msgString=="Tb16") write("Sb17,49");
        if(msgString=="Tb17") write("Sb18,48");
        if(msgString=="Tb18") write("Sb19,53");
        if(msgString=="Tb19") write("Sb20,52");
        if(msgString=="Tb20") write("Sb21,37");
        if(msgString=="Tb21") write("Sb22,38");
        if(msgString=="Tb22") write("Sb23,50");
        if(msgString=="Tb23") write("Sb24,49");
        if(msgString=="Tb24"){
          setState(() {
            aORm = 0;
            patchState = 0;
            measuring = false;
            ledPdSet = true;
          });
          write("status0");
        }
      }
      //
      if(patchState == 2 && msgString.contains("Tagc-B")){
        agcMeasureCount = [0,0,0];

        if(!msgString.contains("Tagc-B0")) agcMsg.add(msgString);

        if(agcMsg.length % 20 == 0 && agcMsg.isNotEmpty){
          var timeStampForDB = DateFormat("yyyy/MM/dd HH:mm:ss.SSS").format(DateTime.now());
          
          List<String> splitForCount = [];

          if(kDebugMode){
            print("=================================================");
            print("timeStamp: $timeStampForDB");
            print("=================================================");
          }
          for(var x in agcMsg){
            splitForCount = x.split(",");
            print("=========================");
            print(x);
            print("=========================");
            print("original : ${double.parse(splitForCount[1].trim())}");
            double two = double.parse(splitForCount[2]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[2]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double three = double.parse(splitForCount[3]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[3]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double four = double.parse(splitForCount[4]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[4]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double five = double.parse(splitForCount[5]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[5]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double six = double.parse(splitForCount[6]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[6]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double seven = double.parse(splitForCount[7]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[7]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double eight = double.parse(splitForCount[8]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[8]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double nine = double.parse(splitForCount[9]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[9]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double ten = double.parse(splitForCount[10]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[10]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();

            double el = double.parse(splitForCount[11]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[11]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double tw = double.parse(splitForCount[12]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[12]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double tht = double.parse(splitForCount[13]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[13]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double fourT = double.parse(splitForCount[14]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[14]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double fifthT = double.parse(splitForCount[15]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[15]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double sixthT = double.parse(splitForCount[16]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[16]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double sevenT = double.parse(splitForCount[17]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[17]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double eightT = double.parse(splitForCount[18]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[18]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double nineT = double.parse(splitForCount[19]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[19]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();

            double twenty = double.parse(splitForCount[20]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[20]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double twentyO = double.parse(splitForCount[21]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[21]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double twentyTwo = double.parse(splitForCount[22]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[22]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double twentyThree = double.parse(splitForCount[23]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[23]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double twentyFour = double.parse(splitForCount[24]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[24]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();
            double twentyFive = double.parse(splitForCount[25]) == 0 ? 0 : (pow(10, (((((double.parse(splitForCount[25]) * 3.3)/4095) * -80.0) + 88) / 20))).toDouble();

            // 총 25개
            if(twentyFive >= 1 && twentyFive < 10000) agcMeasureCount[0]++; if(twentyFive >= 0 && twentyFive < 0.5) agcMeasureCount[1]++; if(twentyFive >= 0.5 && twentyFive < 1) agcMeasureCount[2]++;
            if(two >= 1 && two < 10000) agcMeasureCount[0]++; if(two >= 0 && two < 0.5) agcMeasureCount[1]++;if(two >= 0.5 && two < 1) agcMeasureCount[2]++;
            if(three >= 1 && three < 10000) agcMeasureCount[0]++; if(three >= 0 && three < 0.5) agcMeasureCount[1]++;if(three >= 0.5 && three < 1) agcMeasureCount[2]++;
            if(four >=1 && four < 10000) agcMeasureCount[0]++; if(four >= 0 && four < 0.5) agcMeasureCount[1]++;if(four >= 0.5 && four < 1) agcMeasureCount[2]++;
            if(five > 1 && five < 10000) agcMeasureCount[0]++; if(five >= 0 && five < 0.5) agcMeasureCount[1]++;if(five >= 0.5 && five < 1) agcMeasureCount[2]++;
            if(six > 1 && six < 10000) agcMeasureCount[0]++; if(six >= 0 && six < 0.5) agcMeasureCount[1]++;if(six >= 0.5 && six < 1) agcMeasureCount[2]++;
            if(seven > 1 && seven < 10000) agcMeasureCount[0]++; if(seven >= 0 && seven < 0.5) agcMeasureCount[1]++;if(seven >= 0.5 && seven < 1) agcMeasureCount[2]++;
            if(eight > 1 && eight < 10000) agcMeasureCount[0]++; if(eight >= 0 && eight < 0.5) agcMeasureCount[1]++;if(eight >= 0.5 && eight < 1) agcMeasureCount[2]++;
            if(nine > 1 && nine < 10000) agcMeasureCount[0]++; if(nine >= 0 && nine < 0.5) agcMeasureCount[1]++;if(nine >= 0.5 && nine < 1) agcMeasureCount[2]++;
            if(ten > 1 && ten < 10000) agcMeasureCount[0]++; if(ten >= 0 && ten < 0.5) agcMeasureCount[1]++;if(ten >= 0.5 && ten < 1) agcMeasureCount[2]++;
            if(el > 1 && el < 10000) agcMeasureCount[0]++; if(el >= 0 && el < 0.5) agcMeasureCount[1]++;if(el >= 0.5 && el < 1) agcMeasureCount[2]++;
            if(tw > 1 && tw < 10000) agcMeasureCount[0]++; if(tw >= 0 && tw < 0.5) agcMeasureCount[1]++;if(tw >= 0.5 && tw < 1) agcMeasureCount[2]++;
            if(tht > 1 && tht < 10000) agcMeasureCount[0]++; if(tht >= 0 && tht < 0.5) agcMeasureCount[1]++;if(tht >= 0.5 && tht < 1) agcMeasureCount[2]++;
            if(fourT > 1 && fourT < 10000) agcMeasureCount[0]++; if(fourT >= 0 && fourT < 0.5) agcMeasureCount[1]++;if(fourT >= 0.5 && fourT < 1) agcMeasureCount[2]++;
            if(fifthT > 1 && fifthT < 10000) agcMeasureCount[0]++; if(fifthT >= 0 && fifthT < 0.5) agcMeasureCount[1]++;if(fifthT >= 0.5 && fifthT < 1) agcMeasureCount[2]++;
            if(sixthT > 1 && sixthT < 10000) agcMeasureCount[0]++; if(sixthT >= 0 && sixthT < 0.5) agcMeasureCount[1]++;if(sixthT >= 0.5 && sixthT < 1) agcMeasureCount[2]++;
            if(sevenT > 1 && sevenT < 10000) agcMeasureCount[0]++; if(sevenT >= 0 && sevenT < 0.5) agcMeasureCount[1]++;if(sevenT >= 0.5 && sevenT < 1) agcMeasureCount[2]++;
            if(eightT > 1 && eightT < 10000) agcMeasureCount[0]++; if(eightT >= 0 && eightT < 0.5) agcMeasureCount[1]++;if(eightT >= 0.5 && eightT < 1) agcMeasureCount[2]++;
            if(nineT > 1 && nineT < 10000) agcMeasureCount[0]++; if(nineT >= 0 && nineT < 0.5) agcMeasureCount[1]++;if(nineT >= 0.5 && nineT < 1) agcMeasureCount[2]++;
            if(twenty > 1 && twenty < 10000) agcMeasureCount[0]++; if(twenty >= 0 && twenty < 0.5) agcMeasureCount[1]++;if(twenty >= 0.5 && twenty < 1) agcMeasureCount[2]++;
            if(twentyO > 1 && twentyO < 10000) agcMeasureCount[0]++; if(twentyO >= 0 && twentyO < 0.5) agcMeasureCount[1]++;if(twentyO >= 0.5 && twentyO < 1) agcMeasureCount[2]++;
            if(twentyTwo > 1 && twentyTwo < 10000) agcMeasureCount[0]++; if(twentyTwo >= 0 && twentyTwo < 0.5) agcMeasureCount[1]++;if(twentyTwo >= 0.5 && twentyTwo < 1) agcMeasureCount[2]++;
            if(twentyThree > 1 && twentyThree < 10000) agcMeasureCount[0]++; if(twentyThree >= 0 && twentyThree < 0.5) agcMeasureCount[1]++;if(twentyThree >= 0.5 && twentyThree < 1) agcMeasureCount[2]++;
            if(twentyFour > 1 && twentyFour < 10000) agcMeasureCount[0]++; if(twentyFour >= 0 && twentyFour < 0.5) agcMeasureCount[1]++;if(twentyFour >= 0.5 && twentyFour < 1) agcMeasureCount[2]++;
          }

          ParsingAGC(timeStampForDB, agcMsg);
          if(kDebugMode){
            print("[AIScreen] PARSING DONE");
          }
          setState(() {
            aORm = 0;
            patchState = 0;
            measuredAgc = true;
          });
          write("status0").then((value){measuring = false;});
        }
      }

      if(patchState == 2 && msgString.contains("To")){
        msgString = msgString.replaceAll("To", "");
        temp = double.parse(msgString.trim());
        write("Si");
      }

      if(patchState == 2 && msgString.contains("Ti")){
        tjMsg.add(msgString);

        if(tjMsg.length % 24 == 0 && tjMsg.isNotEmpty){
          var timeStampForDB = DateFormat("yyyy/MM/dd HH:mm:ss.SSS").format(DateTime.now());

          bool lockInIssue = false;
          List<String> split = [];
          List<String> splitForCount = [];

          measureLog.add(timeStampForDB);
          String selectedPdType="initial";

          if(_types == PDTypes.power35) selectedPdType = "35mV";
          if(_types == PDTypes.power20) selectedPdType = "20mV";
          if(_types == PDTypes.power10) selectedPdType = "10mV";
          if(_types == PDTypes.power5) selectedPdType = "5mV";

          for(var x in tjMsg){
            splitForCount = x.split(",");
            if((double.parse(splitForCount[1]) / 8.0) > 700.0) adcMeasureCount[0]++;
            if((double.parse(splitForCount[1]) / 8.0) <= 700.0 && (double.parse(splitForCount[1]) / 8.0) > 500.0) adcMeasureCount[1]++;
            if((double.parse(splitForCount[1]) / 8.0) <= 500.0 && (double.parse(splitForCount[1]) / 8.0) > 300.0) adcMeasureCount[2]++;
            if((double.parse(splitForCount[1]) / 8.0) <= 300.0 && (double.parse(splitForCount[1]) / 8.0) > 200.0) adcMeasureCount[3]++;
            if((double.parse(splitForCount[1]) / 8.0) <= 200.0 && (double.parse(splitForCount[1]) / 8.0) >= 100.0) adcMeasureCount[4]++;
            if((double.parse(splitForCount[1]) / 8.0) < 100.0) adcMeasureCount[5]++;

            if((double.parse(splitForCount[2]) / 8.0) > 700.0) adcMeasureCount[0]++;
            if((double.parse(splitForCount[2]) / 8.0) <= 700.0 && (double.parse(splitForCount[2]) / 8.0) > 500.0) adcMeasureCount[1]++;
            if((double.parse(splitForCount[2]) / 8.0) <= 500.0 && (double.parse(splitForCount[2]) / 8.0) > 300.0) adcMeasureCount[2]++;
            if((double.parse(splitForCount[2]) / 8.0) <= 300.0 && (double.parse(splitForCount[2]) / 8.0) > 200.0) adcMeasureCount[3]++;
            if((double.parse(splitForCount[2]) / 8.0) <= 200.0 && (double.parse(splitForCount[2]) / 8.0) >= 100.0) adcMeasureCount[4]++;
            if((double.parse(splitForCount[2]) / 8.0) < 100.0) adcMeasureCount[5]++;

            if((double.parse(splitForCount[3]) / 8.0) > 700.0) adcMeasureCount[0]++;
            if((double.parse(splitForCount[3]) / 8.0) <= 700.0 && (double.parse(splitForCount[3]) / 8.0) > 500.0) adcMeasureCount[1]++;
            if((double.parse(splitForCount[3]) / 8.0) <= 500.0 && (double.parse(splitForCount[3]) / 8.0) > 300.0) adcMeasureCount[2]++;
            if((double.parse(splitForCount[3]) / 8.0) <= 300.0 && (double.parse(splitForCount[3]) / 8.0) > 200.0) adcMeasureCount[3]++;
            if((double.parse(splitForCount[3]) / 8.0) <= 200.0 && (double.parse(splitForCount[3]) / 8.0) >= 100.0) adcMeasureCount[4]++;
            if((double.parse(splitForCount[3]) / 8.0) < 100.0) adcMeasureCount[5]++;

            if((double.parse(splitForCount[4]) / 8.0) > 700.0) adcMeasureCount[0]++;
            if((double.parse(splitForCount[4]) / 8.0) <= 700.0 && (double.parse(splitForCount[4]) / 8.0) > 500.0) adcMeasureCount[1]++;
            if((double.parse(splitForCount[4]) / 8.0) <= 500.0 && (double.parse(splitForCount[4]) / 8.0) > 300.0) adcMeasureCount[2]++;
            if((double.parse(splitForCount[4]) / 8.0) <= 300.0 && (double.parse(splitForCount[4]) / 8.0) > 200.0) adcMeasureCount[3]++;
            if((double.parse(splitForCount[4]) / 8.0) <= 200.0 && (double.parse(splitForCount[4]) / 8.0) >= 100.0) adcMeasureCount[4]++;
            if((double.parse(splitForCount[4]) / 8.0) < 100.0) adcMeasureCount[5]++;

            if((double.parse(splitForCount[5]) / 8.0) > 700.0) adcMeasureCount[0]++;
            if((double.parse(splitForCount[5]) / 8.0) <= 700.0 && (double.parse(splitForCount[5]) / 8.0) > 500.0) adcMeasureCount[1]++;
            if((double.parse(splitForCount[5]) / 8.0) <= 500.0 && (double.parse(splitForCount[5]) / 8.0) > 300.0) adcMeasureCount[2]++;
            if((double.parse(splitForCount[5]) / 8.0) <= 300.0 && (double.parse(splitForCount[5]) / 8.0) > 200.0) adcMeasureCount[3]++;
            if((double.parse(splitForCount[5]) / 8.0) <= 200.0 && (double.parse(splitForCount[5]) / 8.0) >= 100.0) adcMeasureCount[4]++;
            if((double.parse(splitForCount[5]) / 8.0) < 100.0) adcMeasureCount[5]++;

            if((double.parse(splitForCount[6]) / 8.0) > 700.0) adcMeasureCount[0]++;
            if((double.parse(splitForCount[6]) / 8.0) <= 700.0 && (double.parse(splitForCount[6]) / 8.0) > 500.0) adcMeasureCount[1]++;
            if((double.parse(splitForCount[6]) / 8.0) <= 500.0 && (double.parse(splitForCount[6]) / 8.0) > 300.0) adcMeasureCount[2]++;
            if((double.parse(splitForCount[6]) / 8.0) <= 300.0 && (double.parse(splitForCount[6]) / 8.0) > 200.0) adcMeasureCount[3]++;
            if((double.parse(splitForCount[6]) / 8.0) <= 200.0 && (double.parse(splitForCount[6]) / 8.0) >= 100.0) adcMeasureCount[4]++;
            if((double.parse(splitForCount[6]) / 8.0) < 100.0) adcMeasureCount[5]++;
          }

          // TODO: 여기서 adc 값이 절대값 20000 보다 이하 ==> 좋은 값 // 그게 아니면 comment를 lockin issue라고 바꾸고 넣고 + soft reboot
          if(countMeasure == 0){
            for(var x in tjMsg){
              split = x.split(",");
              if(double.parse(split[1]).abs() > 20000.0){
                lockInIssue = true;
                print("Lock-In Issue");
                break;
              }
              if(double.parse(split[2]).abs() > 20000.0){
                lockInIssue = true;
                print("Lock-In Issue");
                break;
              }
              if(double.parse(split[3]).abs() > 20000.0){
                lockInIssue = true;
                print("Lock-In Issue");
                break;
              }
              if(double.parse(split[4]).abs()> 20000.0){
                lockInIssue = true;
                print("Lock-In Issue");
                break;
              }
              if(double.parse(split[5]).abs() > 20000.0){
                lockInIssue = true;
                print("Lock-In Issue");
                break;
              }
              if(double.parse(split[6]).abs() > 20000.0){
                lockInIssue = true;
                print("Lock-In Issue");
                break;
              }
            }

            // if(lockInIssue == true){
            //   setState(() {
            //     comment = "LOCK-IN ISSUE";
            //   });
            // }

          }

          if(lockInIssue && countMeasure == 0){
            parsingMeasured(timeStampForDB, batteryMeasure, temp, accX, accY, accZ, gyrX, gyrY, gyrZ, "LOCK-IN ISSUE", volume, selectedPdType, tjMsg);
          } else {
            parsingMeasured(timeStampForDB, batteryMeasure, temp, accX, accY, accZ, gyrX, gyrY, gyrZ, comment, volume, selectedPdType, tjMsg);
          }

          if(lockInIssue == true && countMeasure == 0){
            write("status0");
            write("status1");
            print("Soft REBOOT");
            countReboot++;
            print("Soft Rebooted $countReboot times");
            countMeasure = -1;
          }

          if(countMeasure < 4){
            setState(() {
              countMeasure++;
            });
            adcMeasureCount = [0,0,0,0,0,0];
            write("St");
          } else {
            setState(() {
              var simpleTimeStamp = DateFormat("HH:mm").format(DateTime.now());

              simpleMeasureLog.add(simpleTimeStamp);
              aORm = 0;
              patchState = 0;
              countMeasure = 0;
            });

            write("status0").then((value){
              setState(() {
                measuring = false;
                lockInIssue = false;
              });
            });
          }


          tjMsg.clear();
        }

      }
    }

    if (kDebugMode) {
      int count = 0;
      print("value : $msgString");
      print("------------printing msg---------------");
      for(var element in msg){
        count++;
        print("$count : $element");
      }
      print("listening");
    }
  }

  Future write(String text) async {
    try {
      msg.add("[AIScreen] write(): $text");
      text += "\r";

      await device.discoverServices();
      if(kDebugMode){
        print("[AIScreen] write() discoverServices then");
      }
      await characteristic[idxRx].write(utf8.encode(text), withoutResponse: characteristic[idxRx].properties.writeWithoutResponse);
      if(kDebugMode){
        print("[AIScreen] write() write characteristic[idxTx] then");
      }

      if (kDebugMode) {
        print("[AIScreen] wrote: $text");
        print("[AIScreen] write() _lastValueSubscription paused?: ${_lastValueSubscription.isPaused == true}");
      }
    } catch (e) {
      if(kDebugMode){
        print("[AIScreen] wrote error\nError: $e");
      }
    }
  }

  String timeStamp(){
    DateTime now = DateTime.now();
    String formattedTime = DateFormat.Hms().format(now);
    return formattedTime;
  }

  bottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, bottom: 20,),
                      child: Text("Measuring", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                    ),
                    Spacer(flex: 1,),
                  ],
                ),
                TextFormField(
                  autofocus: true,
                  controller: volumeTextController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter Volume';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'eg. 150',
                    labelText: 'Volume',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value){
                  },
                  keyboardType: TextInputType.text,
                  controller: commentTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'eg. type1',
                    labelText: 'Comment',
                    contentPadding: EdgeInsets.only(top: 30, bottom: 30, right: 10, left: 10,),
                  ),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: () {
                    measuring = true;
                    volume = int.parse(volumeTextController.text);
                    aORm = 2;
                    comment = commentTextController.text;
                    write("St");
                    commentTextController.clear();
                    volumeTextController.clear();
                    commentLog.add(comment);
                    volumeLog.add(volume.toString());
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'),
                ),
                const SizedBox(height: 30,),
              ],
            ),
          ),
        );
      },
    );
  }

  void sharing() async {
    String path = p.join(await getDatabasesPath(), 'mediLight.db');
    Share.shareXFiles([XFile(path)],text: "Share Database", subject: "Database");
  }

  Widget selectingTypes(){
    return Column(
      children: [
        RadioListTile<PDTypes>(
          value: PDTypes.power35,
          groupValue: _types,
          onChanged: (PDTypes? value){
            setState(() {
              _types = value;
              aORm = 3;
            });
            write("St");
          },
          title: const Text("35mV"),
        ),

        RadioListTile<PDTypes>(
          value: PDTypes.power20,
          groupValue: _types,
          onChanged: (PDTypes? value){
            setState(() {
              _types = value;
              aORm = 3;
            });
            write("St");
          },
          title: const Text("20mV"),
        ),

        RadioListTile<PDTypes>(
          value: PDTypes.power10,
          groupValue: _types,
          onChanged: (PDTypes? value){
            setState(() {
              _types = value;
              aORm = 3;
            });
            write("St");
          },
          title: const Text("10mV"),
        ),

        RadioListTile<PDTypes>(
          value: PDTypes.power5,
          groupValue: _types,
          onChanged: (PDTypes? value){
            setState(() {
              _types = value;
              aORm = 3;
            });
            write("St");
          },
          title: const Text("5mV"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(_scrollController.hasClients){
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 10,),
            curve: Curves.linear);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Data Collecting", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,),),
        elevation: 1.0,
        backgroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        leading: TextButton(
          child: const Text("Other patch", style: TextStyle(color: Colors.blueAccent),),
          onPressed: () {
            write("Sr").then((_){
              device.disconnect().then((_){
                Navigator.pop(context);
              });
            });
          },
        ),
        leadingWidth: 90,
        actions: [
          const Icon(Icons.bolt_rounded, color: Colors.greenAccent),
          Text("$battery%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          const SizedBox(width: 20,),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20,),

                ledPdSet? Text("Power: ${_types.toString().replaceAll("PDTypes.power", "")}mV\n--------------------------------------------\nSoft Rebooted $countReboot times", style: const TextStyle(fontSize: 18,), textAlign: TextAlign.center,)
                    : selectingTypes(),

                const SizedBox(height: 15,),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: !measuredAgc?
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(126, 189, 194, 1),
                    ),
                    onPressed: ledPdSet? (){
                      patchState = 0;
                      measuring = true;
                      aORm = 1;
                      write("St");
                    } : null,
                    child: const Text("Optimization", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  )
                  : const FilledButton(
                    onPressed: null,
                    child: Text("Optimization Done", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  ),
                ),

                ledPdSet? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ledPdSet? Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xffBC7FCD),
                          ),
                          onPressed: (){
                            setState(() {
                              measuredAgc = false;
                              ledPdSet = false;
                            });
                          },
                          child: const Text("Power Reset", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                        ),
                      ),
                    ) : Container(),

                    measuredAgc? const SizedBox(width: 40,) : Container(),
                    measuredAgc? Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff7469B6),
                          ),
                          onPressed: (){
                            setState(() {
                              measuredAgc = false;
                            });
                          },
                          child: const Text("AGC AGAIN", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                        ),
                      ),
                    ) : Container(),
                  ],
                ):Container(),

                const SizedBox(height: 30,),

                !measuredAgc?
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(126, 189, 194, 1),
                    ),
                    onPressed: null,
                    child: const Text("Measure", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  ),
                ):
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(126, 189, 194, 1),
                    ),
                    onPressed: (){
                      bottomSheet(context);
                    },
                    child: const Text("Measure", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                  ),
                ),

                const SizedBox(height: 15,),

                measuredAgc?
                ExpansionTile(
                  title: const Text("AGC Measurement"),
                  children: [
                    SizedBox(
                      width: 300,
                      child: Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FixedColumnWidth(210),
                          1: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(
                            children: [
                              Container(
                                color: Colors.black12,
                                height: 32,
                                child: const Center(child: Text("1 <= AGC 1 < 10000", style: TextStyle(fontSize: 18,),)),
                              ),
                              SizedBox(
                                height: 32,
                                child: Center(child: Text("${agcMeasureCount[0]}", style: const TextStyle(fontSize: 18,))),
                              ),
                            ]
                          ),
                          TableRow(
                            children: [
                              Container(
                                color: Colors.black12,
                                height: 32,
                                child: const Center(child: Text("0.5 <= AGC 0.5 < 1", style: TextStyle(fontSize: 18,),),),
                              ),
                              SizedBox(
                                height: 32,
                                child: Center(child: Text("${agcMeasureCount[2]}", style: const TextStyle(fontSize: 18,),)),
                              ),
                            ]
                          ),
                          TableRow(
                            children: [
                              Container(
                                color: Colors.black12,
                                height: 32,
                                child: const Center(child: Text("0 <= AGC < 0.5", style: TextStyle(fontSize: 18,),)),
                              ),
                              SizedBox(
                                height: 32,
                                child: Center(child: Text("${agcMeasureCount[1]}", style: const TextStyle(fontSize: 18,),)),
                              ),
                            ]
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15,),
                  ],
                ) : Container(),

                measuredAgc?
                ExpansionTile(
                  title: const Text("ADC Measurement"),
                  children: [
                    SizedBox(
                      width: 300,
                      child: Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FixedColumnWidth(210),
                          1: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(
                              children: [
                                Container(
                                  color: Colors.lightBlue.shade50,
                                  height: 32,
                                  child: const Center(child: Text("700 < ADC", style: TextStyle(fontSize: 18,),)),
                                ),
                                SizedBox(
                                  height: 32,
                                  child: Center(child: Text("${adcMeasureCount[0]}", style: const TextStyle(fontSize: 18,))),
                                ),
                              ]
                          ),
                          TableRow(
                              children: [
                                Container(
                                  color: Colors.lightBlue.shade50,
                                  height: 32,
                                  child: const Center(child: Text("500 < ADC <=700", style: TextStyle(fontSize: 18,),),),
                                ),
                                SizedBox(
                                  height: 32,
                                  child: Center(child: Text("${adcMeasureCount[1]}", style: const TextStyle(fontSize: 18,),)),
                                ),
                              ]
                          ),
                          TableRow(
                              children: [
                                Container(
                                  color: Colors.lightBlue.shade50,
                                  height: 32,
                                  child: const Center(child: Text("300 < ADC <= 500", style: TextStyle(fontSize: 18,),),),
                                ),
                                SizedBox(
                                  height: 32,
                                  child: Center(child: Text("${adcMeasureCount[2]}", style: const TextStyle(fontSize: 18,))),
                                ),
                              ]
                          ),
                          TableRow(
                              children: [
                                Container(
                                  color: Colors.lightBlue.shade50,
                                  height: 32,
                                  child: const Center(child: Text("200 < ADC <= 300", style: TextStyle(fontSize: 18,),),),
                                ),
                                SizedBox(
                                  height: 32,
                                  child: Center(child: Text("${adcMeasureCount[3]}", style: const TextStyle(fontSize: 18,),)),
                                ),
                              ]
                          ),
                          TableRow(
                              children: [
                                Container(
                                  color: Colors.lightBlue.shade50,
                                  height: 32,
                                  child: const Center(child: Text("100 <= ADC <= 200", style: TextStyle(fontSize: 18,),),),
                                ),
                                SizedBox(
                                  height: 32,
                                  child: Center(child: Text("${adcMeasureCount[4]}", style: const TextStyle(fontSize: 18,),)),
                                ),
                              ]
                          ),
                          TableRow(
                              children: [
                                Container(
                                  color: Colors.lightBlue.shade50,
                                  height: 32,
                                  child: const Center(child: Text("ADC < 100", style: TextStyle(fontSize: 18,),),),
                                ),
                                SizedBox(
                                  height: 32,
                                  child: Center(child: Text("${adcMeasureCount[5]}", style: const TextStyle(fontSize: 18,),)),
                                ),
                              ]
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15,),
                  ],
                ) : Container(),

                const Divider(thickness: 2.0, height: 10,),

                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 10,),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.book),
                        const SizedBox(width: 10,),
                        const Text("Measured Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,),),
                        IconButton(
                          onPressed: (){
                            sharing();
                          },
                          icon: const Icon(Icons.share),
                        ),
                      ],
                    ),
                  ),
                ),

                simpleMeasureLog.isNotEmpty?
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black12,
                    ),
                    height: 150,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25, top: 15),
                        child: ListView.builder(
                            controller: _scrollController,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: simpleMeasureLog.length,
                            reverse: true,
                            itemBuilder: (context, index){
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "T: ${simpleMeasureLog[index]} | V: ${volumeLog[index]} | C: ${commentLog[index]}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: index % 2 == 0? Colors.blue : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                ],
                              );
                            }
                        ),
                      ),
                    ),
                  ),
                ): Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black12,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20, top: 20,),
                      child: Text("There no measurement, yet", style: TextStyle(fontSize: 17, color: Colors.black54,),),
                    ),
                  ),
                ),
                // const Spacer(flex: 1,),

                const Divider(thickness: 2.0, height: 80,),

                ExpansionTile(
                  title: const Text('Command Manually'),
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: TextField(
                            controller: cmdController,
                          ),
                        ),
                        TextButton(
                          onPressed: (){
                            setState(() {
                              patchState = 100;
                            });
                            write(cmdController.text);
                            setState(() {
                              patchState = 0;
                            });
                            cmdController.clear();
                          },
                          child: const Text("Enter"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20,),

                    if(msg.isNotEmpty) Text(msg.last),

                    const SizedBox(height: 20,),

                    msg.isNotEmpty?
                    ExpansionTile(
                      title: const Text("See all return msg"),
                      children: [
                        SizedBox(
                          height: 500,
                          child: ListView.builder(
                            itemCount: msg.length,
                            itemBuilder: (context, index){
                              return ListTile(
                                title: Text(msg[index]),
                              );
                            }
                          ),
                        ),
                      ],
                    ):Container(),
                  ],
                ),

                const SizedBox(height: 90,),
              ],
            ),
          ),
          Offstage(
            offstage: !measuring,
            child: const Stack(
              children: [
                Opacity(
                  opacity: 0.5,
                  child: ModalBarrier(dismissible: false, color: Colors.black,),
                ),
                Center(child: CircularProgressIndicator(),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
