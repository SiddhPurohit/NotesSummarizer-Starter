import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'note_model.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key, required this.id});

  final String id;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _summary = '';
  bool _isSummaryLoading = false;
  Note note = Note(
    id: '',
    title: '',
    content: '',
    summary: '',
    lastEdited: DateTime.now(),
  );

  void _loadNote() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final notesStr = _prefs.getStringList('notes');
    if (notesStr != null) {
      final notes =
          notesStr.map((note) => Note.fromJson(jsonDecode(note))).toList();
      final note = notes.firstWhere((note) => note.id == widget.id);
      _titleController.text = note.title;
      _contentController.text = note.content;
      setState(() {
        _summary = note.summary;
      });
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      final notesStr = _prefs.getStringList('notes');
      if (notesStr != null) {
        final notes =
            notesStr.map((note) => Note.fromJson(jsonDecode(note))).toList();
        final index = notes.indexWhere((note) => note.id == widget.id);
        if (index != -1) {
          notes[index] = Note(
            id: widget.id,
            title: _titleController.text,
            content: _contentController.text,
            summary: _summary,
            lastEdited: DateTime.now(),
          );
          await _prefs.setStringList(
            'notes',
            notes.map((note) => jsonEncode(note.toJson())).toList(),
          );
        }
      }
    }
  }

  void _deleteNote() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    final notesStr = _prefs.getStringList('notes');
    if (notesStr != null) {
      final notes =
          notesStr.map((note) => Note.fromJson(jsonDecode(note))).toList();
      final index = notes.indexWhere((note) => note.id == widget.id);
      if (index != -1) {
        notes.removeAt(index);
        await _prefs.setStringList(
          'notes',
          notes.map((note) => jsonEncode(note.toJson())).toList(),
        );
        Navigator.of(context).pop();
      }
    }
  }


  @override
  void initState() {
    _loadNote();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        elevation: 0,
        leading: Card(
          color: Colors.grey[900],
          elevation: 5,
          child: InkWell(
            onTap: () {
              _saveNote();
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          // Card(
          //   color: Colors.grey[900],
          //   elevation: 5,
          //   child: InkWell(
          //     onTap: (){},
          //     child: const Padding(
          //       padding: EdgeInsets.all(8.0),
          //       child: Icon(
          //         Icons.chat_rounded,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
          Card(
            color: Colors.grey[900],
            elevation: 5,
            child: InkWell(
              onTap: _deleteNote,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isSummaryLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: Colors.white,
                    maxLines: 3,
                    minLines: 1,
                    onEditingComplete: _saveNote,
                    decoration: const InputDecoration(
                      hintText: "Title",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _contentController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: Colors.white,
                      maxLines: null,
                      onEditingComplete: _saveNote,
                      decoration: const InputDecoration(
                        hintText: "Content",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _summary.isNotEmpty
                      ? const Divider(
                          color: Colors.white,
                        )
                      : Container(),
                  // _summary.isNotEmpty
                  //     ? SizedBox(
                  //         height: MediaQuery.of(context).size.height * 0.2,
                  //         child: ListView(
                  //           children: [
                  //             Padding(
                  //               padding: const EdgeInsets.all(16.0),
                  //               child: MarkdownBody(
                  //                 data: _summary,
                  //                 styleSheet: MarkdownStyleSheet(
                  //                   p: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 18,
                  //                     fontWeight: FontWeight.w400,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       )
                  //     :
                    const SizedBox(),

                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _saveNote();
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.check),
      )
    );
  }
}
