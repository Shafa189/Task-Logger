import 'package:flutter/material.dart';
import 'package:klp5_mp/API/connect.dart';
import 'package:klp5_mp/Models/User.dart';
import 'package:klp5_mp/arcive.dart';
import 'package:klp5_mp/board.dart';
import 'package:klp5_mp/home.dart';
import 'package:klp5_mp/login.dart';
import 'package:klp5_mp/newpage.dart';
import 'package:klp5_mp/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  UserData _userData = UserData();

  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            accountName: Text(_userData.username ?? 'Guest'),
            accountEmail: Text(_userData.email ?? 'guest@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                ApiConnect.hostConnect + "/assets/" + (_userData.image ?? ''),
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          ListTile(
            title: Text('New'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewPage()),
              );
            },
          ),
          ListTile(
            title: Text('Archives'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArchivesPage()),
              );
            },
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          ListTile(
            title: Text('Log Out'),
            onTap: () {
              Navigator.pop(context);
              remove();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> remove() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('user_id');
      return true; // Penyimpanan berhasil
    } catch (e) {
      print("Error saving user_id to SharedPreferences: $e");
      return false; // Penyimpanan gagal
    }
  }

  Future<void> getUserData() async {
    // Retrieve user ID from SharedPreferences for API authentication.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    print("$userId Ini Session");
    try {
      // Send a POST request to the API to fetch user data.
      final response = await http.post(Uri.parse(ApiConnect.getuser), body: {
        "userId": userId.toString(),
      });

      if (response.statusCode == 200) {
        // Parse the JSON response and convert it to a UserData object.
        print(response.body);
        Map<String, dynamic> userData = jsonDecode(response.body);
        UserData user = UserData.fromJson(userData);
        print(user);
        setState(() {
          _userData = user;
        });
      }
    } catch (e) {
      // Handle any errors that occur during the API request.
      print(e.toString());
    }
  }
}
