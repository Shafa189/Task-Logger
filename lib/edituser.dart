import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klp5_mp/API/connect.dart';
import 'package:klp5_mp/Models/User.dart';
import 'package:klp5_mp/board.dart';
import 'package:klp5_mp/main.dart';
import 'package:klp5_mp/setting.dart';
import 'package:klp5_mp/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class EditUser extends StatefulWidget {
  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  UserData _userData = UserData();
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Settings",
            style: TextStyle(color: Colors.white),
          ),
        ),
        drawer: SideBar(),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          top: 2,
                          bottom: 10,
                          left: 10,
                          right: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: _userData.username,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors
                                .white, // Set the text color for the entered text
                          ),
                          cursorColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 2,
                          bottom: 10,
                          left: 10,
                          right: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors
                                .white, // Set the text color for the entered text
                          ),
                          cursorColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 2,
                          bottom: 10,
                          left: 10,
                          right: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: _userData.email,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors
                                .white, // Set the text color for the entered text
                          ),
                          cursorColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(
                          top: 2,
                          bottom: 10,
                          left: 10,
                          right: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: _userData.address,
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors
                                .white, // Set the text color for the entered text
                          ),
                          cursorColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    edit(); // Ensure edit is a valid function
                  },
                  child: Container(
                    height: 60,
                    width: 140,
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 10,
                      right: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    child: Center(
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
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

  Future<void> edit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    // String date = DateTime.now().toString();
    print("$userId Ini Session");
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConnect.editusers),
      );

      request.fields.addAll({
        "userId": userId.toString(),
        "username": usernameController.text,
        "password": passwordController.text,
        "email": emailController.text,
        "address": addressController.text,
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> user = jsonDecode(responseBody);
        print(responseBody);

        if (user['success'] == true) {
          final int userId = user['data']['userId'];
          print(user);

          // Jika penyimpanan berhasil, lanjutkan dengan navigasi
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
          // Print hasil setelah berhasil menyimpan ke session manager
          print("User ID berhasil disimpan di SharedPreferences: $userId");
        }
      } else {
        // Handle response status code other than 200
        print("HTTP request failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("Error during registration: $e");
    }
  }
}
