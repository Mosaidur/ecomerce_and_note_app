import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecom_and_note_app/feature/notes/data/models/note_model.dart';
import 'package:ecom_and_note_app/feature/notes/domain/repository/note_repository.dart';
import 'package:uuid/uuid.dart';

class NoteRepositoryImpl implements NoteRepository {
  final String apiUrl = 'https://jsonplaceholder.typicode.com/posts';
  static const String _notesKey = 'notes';
  final SharedPreferences prefs;

  NoteRepositoryImpl(this.prefs);

  @override
  Future<List<NoteModel>> getNotes() async {
    final notesJson = prefs.getString(_notesKey);
    if (notesJson == null) return [];
    final List<dynamic> notesList = jsonDecode(notesJson);
    return notesList.map((json) => NoteModel.fromJson(json)).toList();
  }

  @override
  Future<void> addNote(NoteModel note) async {
    note.id = const Uuid().v4();
    note.lastModified = DateTime.now();
    final notes = await getNotes();
    notes.add(note);
    await prefs.setString(_notesKey, jsonEncode(notes.map((n) => n.toJson()).toList()));
    await _syncNote(note);
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    note.lastModified = DateTime.now();
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      await prefs.setString(_notesKey, jsonEncode(notes.map((n) => n.toJson()).toList()));
      await _syncNote(note);
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    await prefs.setString(_notesKey, jsonEncode(notes.map((n) => n.toJson()).toList()));
    try {
      await http.delete(Uri.parse('$apiUrl/$id'));
    } catch (e) {
      // Log error, but don't fail the operation
    }
  }

  @override
  Future<void> syncNotes() async {
    final notes = await getNotes();
    final unsyncedNotes = notes.where((note) => !note.isSynced).toList();
    for (var note in unsyncedNotes) {
      await _syncNote(note);
    }
  }

  Future<void> _syncNote(NoteModel note) async {
    try {
      final response = note.isSynced
          ? await http.put(
        Uri.parse('$apiUrl/${note.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': note.id,
          'title': note.title,
          'body': note.content,
          'userId': 1,
        }),
      )
          : await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': note.title,
          'body': note.content,
          'userId': 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final notes = await getNotes();
        final index = notes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          notes[index].isSynced = true;
          await prefs.setString(_notesKey, jsonEncode(notes.map((n) => n.toJson()).toList()));
        }
      }
    } on SocketException {
      // Handle offline case
      note.isSynced = false;
      final notes = await getNotes();
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notes[index] = note;
        await prefs.setString(_notesKey, jsonEncode(notes.map((n) => n.toJson()).toList()));
      }
    } catch (e) {
      // Log error
      note.isSynced = false;
      final notes = await getNotes();
      final index = notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        notes[index] = note;
        await prefs.setString(_notesKey, jsonEncode(notes.map((n) => n.toJson()).toList()));
      }
    }
  }
}