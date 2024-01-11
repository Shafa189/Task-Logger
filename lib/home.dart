import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:klp5_mp/API/connect.dart';
import 'package:klp5_mp/API/service.dart';
import 'package:klp5_mp/Models/Act.dart';
import 'package:klp5_mp/Models/User.dart';
import 'package:klp5_mp/arcive.dart';
import 'package:klp5_mp/board.dart';
import 'package:klp5_mp/editact.dart';
import 'package:klp5_mp/login.dart';
import 'package:klp5_mp/newpage.dart';
import 'package:klp5_mp/search_input.dart';
import 'package:klp5_mp/sidebar.dart';
import 'package:klp5_mp/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ServiceApiAktiv _serviceApiAktiv;
  late TextEditingController _inputSearchController;
  List<NoteData> _notesList = [];
  late Timer _debounce;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    getUserData();
    _inputSearchController = TextEditingController();
    _serviceApiAktiv = ServiceApiAktiv();
    _debounce = Timer(Duration(milliseconds: 500), () {});
    _focusNode = FocusNode();

    // Request focus on the search bar when the screen loads
    _focusNode.requestFocus();

    _loadData();
  }

  // Function to load notes data with debounce for search input.
  Future<void> _loadData() async {
    try {
      // Clear existing debounce timer
      if (_debounce.isActive) _debounce.cancel();

      // Set up a new debounce timer
      _debounce = Timer(Duration(milliseconds: 500), () async {
        List<NoteData> data = await _serviceApiAktiv.getData();

        // Filter the notes based on the search query
        String query = _inputSearchController.text.toLowerCase();
        if (query.isNotEmpty) {
          data = data
              .where((notes) =>
                  notes.title!.toLowerCase().contains(query) ||
                  notes.description!.toLowerCase().contains(query) ||
                  notes.image!.toLowerCase().contains(query))
              .toList();
        }

        setState(() {
          _notesList = data;
        });
      });
    } catch (e) {
      log('Error loading data: $e');
    }
  }

  @override
  void dispose() {
    // Dispose of the focus node when the widget is disposed
    _focusNode.dispose();
    _debounce.cancel();
    super.dispose();
  }

  UserData _userData = UserData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text(
          'Boards',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Container(
            width: 200,
            child: SearchInput(
              controller: _inputSearchController,
              hint: 'Search',
              onChanged: (query) {
                // Call _loadData when the search input changes
                _loadData();
              },
              focusNode: _focusNode,
            ),
          )
        ],
      ),
      body: _notesList.isEmpty
          ? Center(
              child: Text("Belum ada List Kegiatan"),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                padding: const EdgeInsets.all(16),
                itemCount: _notesList.length,
                itemBuilder: (context, index) {
                  // Individual note widget
                  NoteData notes = _notesList[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the edit screen when a note is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditActPage(
                            id: notes.id ?? '',
                            title: notes.title ?? '',
                            description: notes.description ?? '',
                            image: notes.image ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Image.network(
                            ApiConnect.hostConnect + "/assets/" + notes.image!,
                            height: 100,
                          ),
                          // Note title
                          Text(
                            notes.title ?? 'Title',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 16),
                          // Note date
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        shape: CircleBorder(),
      ),
      drawer: Drawer(
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
              title: Text('Boards'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BoardsPage(),
                  ),
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
