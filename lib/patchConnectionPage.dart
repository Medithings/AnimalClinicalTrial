import 'dart:async';
import 'package:animal_case_study/util/ble_communication.dart';
import 'package:animal_case_study/util/ble_provider.dart';
import 'package:animal_case_study/widget/scan_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import 'dataCollectionPage.dart';

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
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription; // Stream으로 받아오는 scan result list
  final List<ScanResult> _scanResults = []; // FBP에서 제공하는 것 (ScanResult)

  @override
  void initState() {
    super.initState();
    ble.scanningListen();
    ble.scanningStart();
  }

  Widget buildScanButton(BuildContext context) {
    if (_isScanning) {
      return FloatingActionButton(
        onPressed: (){
          ble.scanningStop();
          setState(() {
            _isScanning = false;
          });
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: (){
          ble.scanningStart();
          setState(() {
            _isScanning = true;
          });
        },
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
