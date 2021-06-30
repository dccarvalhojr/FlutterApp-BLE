import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BleManager bleManager = BleManager();
  PermissionStatus permissionStatus;
  List<String> bluetoothDevicesRssi = [];
  List<String> bluetoothDevicesName = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      permissionStatus = await Permission.location.status;

      if (permissionStatus != PermissionStatus.granted) {
        return await Permission.location.request();
      }
    }
  }

  void _createClient() async => await bleManager.createClient();
  void _enableRadio() => bleManager.enableRadio();

  @override
  void dispose() {
    bleManager.destroyClient();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              _createClient();
              _enableRadio();
            },
            icon: Icon(Icons.bluetooth),
          ),
          IconButton(
            onPressed: () {
              bleManager.stopPeripheralScan();
            },
            icon: Icon(
              Icons.stop,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(bluetoothDevicesName[index] ?? 'null'),
              subtitle: Text(bluetoothDevicesRssi[index]),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bleManager.startPeripheralScan().listen((scanResult) {
            //Scan one peripheral and stop scanning
            print(
                "Scanned Peripheral ${scanResult.peripheral.name}, RSSI ${scanResult.rssi}");
            bluetoothDevicesName.add(scanResult.peripheral.name);
            bluetoothDevicesRssi.add(scanResult.rssi.toString());
            setState(() {});
            bluetoothDevicesName.removeRange(
                5, bluetoothDevicesName.length - 5);
            bluetoothDevicesRssi.removeRange(
                5, bluetoothDevicesName.length - 5);
          });
        },
        child: Icon(Icons.bluetooth),
      ),
    );
  }
}
