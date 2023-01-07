// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:monprojet/bluetooth_app.dart';
import 'package:monprojet/model/user_model.dart';
import 'package:monprojet/screens/home.dart';
import 'package:monprojet/screens/login.dart';
class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  NavigationDrawerWidget createState() => NavigationDrawerWidget();
}
class NavigationDrawerWidget extends State<NavigationDrawer> {

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();


  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    return Drawer(
      
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(
               color: Colors.deepPurple,
           ),
            accountName: Text("${loggedInUser.firstName} ${loggedInUser.secondName}"),
            accountEmail: Text("${loggedInUser.email}"),
          ),
           ListTile(
            leading: Icon(Icons.home),
            title: Text('bluetoothAdapter'),
             onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BluetoothApp()));
                            }),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('setting'),
             onTap: () =>  FlutterBluetoothSerial.instance.openSettings(),
          ),
         
          Divider(),
          ListTile(
            leading: Icon(Icons.person_rounded),
            title: Text('details'),
           onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomeScreen()));
                            }),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('delete compte'),
            onTap: () => delete(context),
          ),
          Divider(),
          ListTile(
            title: Text('logout'),
            leading: Icon(Icons.exit_to_app),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
    // the logout function
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
    Future<void> delete(BuildContext context) async {
var user = FirebaseAuth.instance.currentUser;
user!.delete();
final collection = FirebaseFirestore.instance.collection('users');
collection 
    .doc(user.uid) // <-- Doc ID to be deleted. 
    .delete() // <-- Delete
    .then((_) => print('Deleted'))
    .catchError((error) => print('Delete failed: $error'));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
 
}

   
}
