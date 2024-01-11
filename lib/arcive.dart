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

class ArchivesPage extends StatefulWidget {
  @override
  _ArchivesState createState() => _ArchivesState();
}

class _ArchivesState extends State<ArchivesPage> {
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
          'Archives',
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
      body: ListView.separated(
        itemCount: _notesList.length,
        separatorBuilder: (BuildContext context, int index) {
          // Add space between items
          return SizedBox(height: 8);
        },
        itemBuilder: (context, index) {
          NoteData notes = _notesList[index];
          return GestureDetector(
            onTap: () {
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
              margin: const EdgeInsets.only(
                top: 20,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[200]),
              child:
                  // Note title
                  Text(
                notes.title ?? 'Title',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
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
