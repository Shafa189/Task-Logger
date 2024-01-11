import 'dart:io';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klp5_mp/API/connect.dart';
import 'package:klp5_mp/home.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                        top: 2, bottom: 10, left: 10, right: 10),
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
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
                        top: 2, bottom: 10, left: 10, right: 10),
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
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
                        top: 2, bottom: 10, left: 10, right: 10),
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          hintText: 'Nama',
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
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
                        top: 2, bottom: 10, left: 10, right: 10),
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                          hintText: 'Address',
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
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
                String username = usernameController.text;
                String password = passwordController.text;
                registerWithEmailAndPassword(username, password);
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
                    'Register',
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
    );
  }

  void registerWithEmailAndPassword(String email, String password) async {
    try {
      // Pengecekan apakah email sudah terdaftar
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Handle registration success
      print("Registration successful: ${userCredential.user!.uid}");
      register();
    } catch (e) {
      // Handle registration failure
      print("Registration failed: $e");

      // Cek apakah error disebabkan oleh email sudah terdaftar
      if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
        showEmailAlreadyRegisteredDialog(context);

        // Tampilkan toast message bahwa email sudah terdaftar
        // Fluttertoast.showToast(
        //   msg: "Email Sudah Terdaftar",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        //   fontSize: 16.0,
        // );
      }
    }
  }

  Future<void> register() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConnect.register),
      );

      request.fields.addAll({
        "username": usernameController.text,
        "password": passwordController.text,
        "email": emailController.text,
        "address": addressController.text,
      });

      if (image != null) {
        // Menambahkan gambar ke dalam permintaan multipart
        request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(image!.openRead().cast()),
          await image!.length(),
          filename: usernameController.text + '_user_image.jpg',
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> user = jsonDecode(responseBody);
        print(responseBody);

        if (user['success'] == true) {
          final int userId = user['data']['userId'];
          print(user);

          // Coba menyimpan ID user ke dalam session manager
          bool saveSuccess = await saveUserId(userId);

          if (saveSuccess) {
            // Jika penyimpanan berhasil, lanjutkan dengan navigasi
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            // Print hasil setelah berhasil menyimpan ke session manager
            print("User ID berhasil disimpan di SharedPreferences: $userId");
          } else {
            // Handle penyimpanan gagal jika diperlukan
            print("Failed to save user_id to SharedPreferences");
          }
        }
      } else {
        // Handle response status code other than 200
        print("HTTP request failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("Error during registration: $e");
    }
  }

  void showEmailAlreadyRegisteredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pesan"),
          content: Text("Email Sudah Terdaftar"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup popup
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> saveUserId(int userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);
      return true; // Penyimpanan berhasil
    } catch (e) {
      print("Error saving user_id to SharedPreferences: $e");
      return false; // Penyimpanan gagal
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
    setState(() {});
  }

  Future getImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final imagePicked = await picker.pickImage(source: ImageSource.camera);
    image = File(imagePicked!.path);
    setState(() {});
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
                        color: Colors.black,
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
}
