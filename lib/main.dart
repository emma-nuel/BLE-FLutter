import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const SERVICE_UUID      =  "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
const CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
List recievedData = [];
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  late BluetoothDevice device;
  late List<BluetoothService> services;
  late BluetoothCharacteristic characteristic;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: const Duration(seconds: 10));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name == 'ESP32Ble') {
          connectToDevice(result.device);
          break;
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    if (device == null) return;
    await device.connect();
    services = await device.discoverServices();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (BluetoothCharacteristic c in service.characteristics) {
          if (c.uuid.toString() == CHARACTERISTIC_UUID) {
            characteristic = c;
            characteristic.setNotifyValue(true);
            characteristic.value.listen((value) {
              // Handle received data here
              // print("Value: $value");
             
              print('Received data: ${String.fromCharCodes(value)}');
              setState(() {
                recievedData = String.fromCharCodes(value).split(',');
              });            
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Receiver'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Receiving data...'),
            Text("Recieved Data: ${recievedData}")
          ],
        ),

      ),
    );
  }
}
