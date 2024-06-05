import 'dart:async';
import 'package:animal_case_study/util/ble_communication.dart';
import 'package:animal_case_study/util/ble_provider.dart';
import 'package:animal_case_study/widget/scan_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class PatchConnectionPage extends StatefulWidget {
  const PatchConnectionPage({super.key});

  @override
  State<PatchConnectionPage> createState() => _PatchConnectionPageState();
}

class _PatchConnectionPageState extends State<PatchConnectionPage> {
  static const String suid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // nordic uart service uuid
  late BluetoothService? bService;

  bool _isScanning = false; // 초기값 false

  BLECommunication ble = BLECommunication();
  late StreamSubscription<bool> _isScanningSubscription; // Stream으로 bool 값을 가지는 state

  @override
  void initState() {
    super.initState();
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) { // is scanning 을 listen
      _isScanning = state; // listen 해서 받아온 state 를 _isScanning 에 복사
      if (mounted) { // mounted?
        setState(() {}); // set state
      }
    });
    ble.scanningStart();
    ble.scanningListen();
  }

  Widget buildScanButton(BuildContext context) {
    if (_isScanning) {
      return FloatingActionButton(
        onPressed: () => ble.scanningStop(),
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: ()=> ble.scanningStart(),
        child: const Text("SCAN"),
      );
    }
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  void discoveringService(BluetoothDevice d) async{
    for(BluetoothService x in  await d.discoverServices()){
      if(x.uuid.toString().toUpperCase() == suid){
        bService = x;
      }
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    List<ScanResult> temp = context.watch<BLEProvider>().scanResult;
    return temp
        .map(
          (r) => ScanResultTile(
        result: r,
        onTap: () {
          ble.scanningStop();
          ble.onConnect(r.device);
        },
      ),
    )
        .toList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _isScanningSubscription.cancel();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finding Devices'),
        centerTitle: true,
        toolbarHeight: MediaQuery.of(context).size.height * 0.2,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: <Widget>[
            // no need system devices
            // ..._buildSystemDeviceTiles(context),
            ..._buildScanResultTiles(context),
          ],
        ),
      ),
      floatingActionButton: buildScanButton(context),
    );
  }
}
