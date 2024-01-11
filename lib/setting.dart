import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klp5_mp/API/connect.dart';
import 'package:klp5_mp/API/service.dart';
import 'package:klp5_mp/Models/Act.dart';
import 'package:klp5_mp/Models/User.dart';
import 'package:klp5_mp/edituser.dart';
import 'package:klp5_mp/newpage.dart';
import 'package:klp5_mp/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  UserData _userData = UserData();
  File? image;
  void initState() {
    super.initState();
    getUserData();
  }

  // Function to load notes data with debounce for search input.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: SideBar(),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(
              ApiConnect.hostConnect + "/assets/" + (_userData.image ?? ''),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: InkWell(
              onTap: () => _potoBottomSheet(),
              child: Center(
                child: Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 28,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: InkWell(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EditUser()),
              ),
              child: Center(
                child: Text(
                  "Display Option",
                  style: TextStyle(
                    fontSize: 28,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: InkWell(
              onTap: () => _about(),
              child: Center(
                child: Text(
                  "About",
                  style: TextStyle(
                    fontSize: 28,
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
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

  Future<void> getImageGalerry() async {
    var galleryPermission = Permission.storage;

    if (galleryPermission.status == PermissionStatus.denied) {
      galleryPermission.request();
      if (galleryPermission.status == PermissionStatus.permanentlyDenied) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(""))
          ]),
        );
      }
    }

    final ImagePicker picker = ImagePicker();
    final imagePicked = await picker.pickImage(source: ImageSource.gallery);
    image = File(imagePicked?.path ?? "");

    // Call the update function here
    update();

    setState(() {});
  }

  Future getImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final imagePicked = await picker.pickImage(source: ImageSource.camera);
    image = File(imagePicked!.path);

    // Call the update function here
    update();

    setState(() {});
  }

  Future<void> edit() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConnect.editusers),
      );

      request.fields.addAll({
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

  Future _potoBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    onTap: () async {
                      await getImageGalerry();
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text("Upload dari Galeri",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF454444),
                        )),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 15,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      await getImageCamera();
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text("Upload dari Kamera",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF454444),
                        )),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future _about() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 400,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "About",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 26),
                  ),
                  Text(
                    "Aplikasi Task Logger atau bisa disebut aplikasi pancatat tugas yang dapat digunakan untuk mencatat tugas-tugas agar terorganisir supaya mudah ingat. Tampilan aplikasi ini terdiri dari tampilan login, draw menu, dan main screen yang di dalamnya memuat beberapa halaman sekaligus menjadikannya sebuah fitur yaitu home, new, boards, archives, dan settings. Perbedaan aplikasi ini dengan aplikasi pencatat bawaan dari handphone adalah terletak pada fiturnya, yaitu menu login, boards, dan archives yang tidak semua aplikasi pencatat bawaan handphone memilikinya.",
                    textAlign: TextAlign.justify,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> update() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    // String date = DateTime.now().toString();
    print("$userId Ini Session");
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConnect.update),
      );

      request.fields.addAll({
        "userId": userId.toString(),
      });

      if (image != null) {
        // Menambahkan gambar ke dalam permintaan multipart
        request.files.add(http.MultipartFile(
          'newFoto',
          http.ByteStream(image!.openRead().cast()),
          await image!.length(),
          filename: userId.toString() + '_new_user_image.jpg',
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print(responseBody);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
      } else {
        // Handle response status code other than 200
        print("HTTP request failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("Error during registration: $e");
    }
  }
}
