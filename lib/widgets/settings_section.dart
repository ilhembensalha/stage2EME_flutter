import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:monprojet/widget/navigation_drawer_widget.dart';

class SettingSection {
  static settingSection() {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "Settings",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.deepPurple,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        IconButton(
          iconSize: 100,
          icon: Image.asset(
            'assets/images/setting.png',
          ),
          onPressed: () {
            FlutterBluetoothSerial.instance.openSettings();
          },
        ),
        SizedBox(
          height: 10,
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
