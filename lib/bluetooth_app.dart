import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:monprojet/helper/helper.dart';
import 'package:monprojet/widgets/app_bar_actions.dart';
import 'package:monprojet/widgets/get_device_items.dart';
import 'package:monprojet/widgets/send_serial_dialog.dart';
import 'package:monprojet/widgets/settings_section.dart';
import 'package:monprojet/widget/navigation_drawer_widget.dart';

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
 BluetoothConnection? connection;

  int? _deviceState;

  bool isDisconnecting = false;

  final textFieldController = TextEditingController();

 


  bool checkIfPressing = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection!.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    BluetoothHelper.enableBluetooth(_bluetoothState, getPairedDevices);

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();

    }

    super.dispose();
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        drawer: const NavigationDrawer(),
        appBar: AppBar(
          title: Text("bluetooth"),
          backgroundColor: Colors.deepPurple,
          actions: <Widget>[
            AppBarActions.appBarActions(getPairedDevices, _scaffoldKey),
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
             
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Device:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 100,
                      child: DropdownButton(
                        isExpanded: true,
                        items: GetDeviceItems.getDeviceItems(_devicesList),
                        onChanged: (value) => setState(() => _device = value as BluetoothDevice),
                        value: _devicesList.isNotEmpty ? _device : null,
                      ),
                    ),
                    RaisedButton(
                      onPressed: _isButtonUnavailable
                          ? null
                          : _connected ? _disconnect : _connect,
                      child: Text(_connected ? 'Disconnect' : 'Connect'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              
              Divider(),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Sending To Bluetooth",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.deepPurple),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: IconButton(
                  iconSize: 100,
                  icon: Image.asset(
                    'assets/images/chat.png',
                  ),
                  onPressed: () {
                    return SendSerialDialog.showSerialDialog(
                        context,
                        textFieldController,
                        _connected,
                        _scaffoldKey,
                        _sendTextMessageToBluetooth);
                  },
                ),
              ),
              SizedBox(height: 20),
              SettingSection.settingSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Method to connect to bluetooth
  @Deprecated('Use `BluetoothConnection.toAddress(address)` instead')
Future<void> connectToAddress(String? address) => Future(() async {
    await BluetoothConnection.toAddress(address);
    });
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      BluetoothHelper.show(_scaffoldKey, 'No device selected');
    } else {
      if (!isConnected) {
        await connectToAddress(_device!.address)
            .then((_connection) {
          print('Connected to the device');
         // connection = _connection;
          setState(() {
            _connected = true;
          });

          connection!.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        BluetoothHelper.show(_scaffoldKey, 'Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // Method to disconnect bluetooth

  void _disconnect() async {
     
    setState(() {
        _connected = false;
        _isButtonUnavailable = false;
        _deviceState = 0;

    });
     await connection!.close();
     BluetoothHelper.show(_scaffoldKey, 'Device disconnected');
  }

  void _sendTextMessageToBluetooth(String message) async {
    connection!.output.add(utf8.encode(message) as Uint8List);
    await connection!.output.allSent;

    setState(() {
      _deviceState = -1; // device off
    });
  }
  // Method read msg ,
@Deprecated('Use `BluetoothConnection.input` instead')
Stream<Uint8List>? onRead() => connection!.input;
  // Method to show a Snackbar,
  // taking message as the text

}

