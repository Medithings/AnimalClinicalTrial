import 'dart:async';

import 'package:animal_case_study/util/ble_etra.dart';
import 'package:animal_case_study/util/ble_provider.dart';
import 'package:animal_case_study/util/global_variable_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';

import '../dataCollectionPage.dart';

class BLECommunication{
  final context = GlobalVariableSetting.navigatorState.currentContext;
  static const String rx = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // write data to the rx characteristic to send it to the UART interface.
  static const String tx = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // Enable notifications for the tx characteristic to receive data from the application.
  static const String suid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // nordic uart service uuid

  late StreamSubscription<List<int>> _lastValueSubscription;

  late BluetoothDevice device;
  late BluetoothService service;
  late List<BluetoothCharacteristic> characteristic;

  int idxTx = 1;
  int idxRx = 0;

  final List<ScanResult> _scanResults = []; // FBP에서 제공하는 것 (ScanResult)
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription; // Stream으로 받아오는 scan result list
  late StreamSubscription<bool> _isScanningSubscription; // Stream으로 bool 값을 가지는 state

  init(){
    device = context!.read<BLEProvider>().device;
    service = context!.read()<BLEProvider>().service;
    characteristic = service.characteristics;
  }

  void scanningListen(){
    print("Start Listening to scan results");

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((peripheral) {
      _scanResults.clear();
      context!.read<BLEProvider>().scanResult.clear();

      for(var x in peripheral){
        if(x.device.platformName.contains("Bladder") || x.device.platformName.contains("MEDi")){
          if(_scanResults.indexWhere((element) => element.device.remoteId == x.device.remoteId) < 0){
            _scanResults.add(x);
            context!.read<BLEProvider>().scanResult = _scanResults;
          }
        }
      }
    });
  }

  void scanningStart() async {
    try{
      int divisor = Platform.isAndroid ? 8 : 1;
      _scanResults.clear();
      context!.read<BLEProvider>().scanResult.clear();
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10), continuousUpdates: true, continuousDivisor: divisor);
    } catch(e){
      print("[ERR]: BLE scanning error\n[ERR MSG]: $e");
    }
  }

  void scanningStop() async {
    try{
      FlutterBluePlus.stopScan();
    } catch(e){
      print("[ERR]: BLE scanning stop error\n[ERR MSG]: $e");
    }
  }

  void onConnect(BluetoothDevice d) async {
    try{
      await d.connectAndUpdateStream();
      context!.read<BLEProvider>().device = d;
      print("[BLE Communication]: connect SUCEED");
    } catch(e){
      print("[ERR]: BLE device connect error\n[ERR MSG]: $e");
    }

    try{
      for(var x in await d.discoverServices()){
        if(x.uuid.toString().toUpperCase() == suid){
          context!.read<BLEProvider>().service = x;
        }
      }
      print("[BLE Communication]: found service");
    } catch(e){
      print("[ERR]: BLE device's service storing error\n[ERR MSG]: $e");
    }

    Route route = MaterialPageRoute(builder: (context) => const DataCollectionPage());
    Navigator.push(context!, route);
  }

  void checkingChannel(){
    init();

    switch (characteristic.first.uuid.toString().toUpperCase()){
      case rx: idxTx = 1; idxRx = 0;
        print("rx = ${characteristic[idxRx].uuid.toString().toUpperCase()}\ntx = ${characteristic[idxTx].uuid.toString().toUpperCase()}");
      break;
      case tx: idxTx = 0; idxRx = 1;
        print("rx = ${characteristic[idxRx].uuid.toString().toUpperCase()}\ntx = ${characteristic[idxTx].uuid.toString().toUpperCase()}");
      break;
      default: break;
    }

  }

  void listeningStart(){
    checkingChannel();
    _lastValueSubscription = characteristic[idxTx].lastValueStream.listen((value) async {
      String convertedStr = utf8.decode(value).trimRight();
      print("To mobile application (from patch) : $convertedStr");

      context!.read<BLEProvider>().msgAdd = convertedStr;
    });
  }

  void write(String cmd) async {
    try{
      await context!.read<BLEProvider>().device.discoverServices();
      await characteristic[idxRx].write(utf8.encode(cmd), withoutResponse: characteristic[idxRx].properties.writeWithoutResponse);
      print("To patch (from mobile application): $cmd");
    } catch(e){
      print("[ERR]: msg write error\n[ERR MSG]: $e");
    }
  }

  void cancelListen(){
    _scanResultsSubscription.cancel();
    _lastValueSubscription.cancel();
  }
}