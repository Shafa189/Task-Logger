import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:klp5_mp/API/connect.dart';
import 'package:klp5_mp/API/service.dart';
import 'package:klp5_mp/Models/Act.dart';
import 'package:klp5_mp/editact.dart';
import 'package:klp5_mp/newpage.dart';
import 'package:klp5_mp/search_input.dart';
import 'package:klp5_mp/sidebar.dart';

class BoardsPage extends StatefulWidget {
  @override
  _BoardsState createState() => _BoardsState();
}

class _BoardsState extends State<BoardsPage> {
  late ServiceApiAktiv _serviceApiAktiv;
  late TextEditingController _inputSearchController;
  List<NoteData> _notesList = [];
  late Timer _debounce;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
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
      drawer: SideBar(),
      body: Padding(
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
    );
  }
}
