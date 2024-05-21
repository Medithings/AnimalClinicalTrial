import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEProvider extends ChangeNotifier{
  final List<BluetoothDevice> _device = [];
  final List<BluetoothService> _service = [];
  final List<String> _msg = [];
  List<ScanResult> _scanResult = [];
  int _battery = 0;

  BluetoothDevice get device => _device.first;
  BluetoothService get service => _service.first;
  List<String> get msg => _msg;
  List<ScanResult> get scanResult => _scanResult;
  int get battery => _battery;

  set device(BluetoothDevice d){
    _device.add(d);
    notifyListeners();
    print("[Provider] device: ${_device.first.platformName}");
  }

  set service(BluetoothService s){
    _service.add(s);
    notifyListeners();
    print("[Provider] service: ${_service.first.uuid}");
  }

  set msgAdd(String str){
    _msg.add(str);
    notifyListeners();
    print("[Provider] msgAdd: ${_msg.last.toString()}");
  }

  set scanResult(List<ScanResult> x){
    _scanResult = x;
    notifyListeners();
    print("[Provider] scanResult: ${_scanResult.first.device.platformName}");
  }

  set battery(int b){
    _battery = b;
    notifyListeners();
    print("[Provider] battery: $battery");
  }
}