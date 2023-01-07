import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:monprojet/helper/helper.dart';
import 'package:monprojet/widget/navigation_drawer_widget.dart';

class AppBarActions {
  static appBarActions(getPairedDevices, _scaffoldKey) {
     backgroundColor: Colors.deepPurple;
    return Column(
      children: [
        
        FlatButton.icon(
          icon: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          label: Text(
            "Refresh",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          splashColor: Colors.deepPurple,
          onPressed: () async {
         
            await getPairedDevices().then((_) {
              BluetoothHelper.show(_scaffoldKey, 'Device list refreshed');
            });
          },
        ),
      ],
    );
  }
}
