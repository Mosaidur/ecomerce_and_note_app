import 'package:flutter/material.dart';
import 'package:ecom_and_note_app/feature/notes/data/models/note_model.dart';
import 'package:ecom_and_note_app/feature/notes/domain/repository/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository repository;
  List<NoteModel> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;

  NoteProvider({required this.repository});

  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotes() async {
    try {
      _isLoading = true;
      notifyListeners();
      _notes = await repository.getNotes();
      await repository.syncNotes();
      _notes = await repository.getNotes();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load notes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(String title, String content, String tagColor) async {
    try {
      _isLoading = true;
      notifyListeners();
      final note = NoteModel(
        id: '',
        title: title,
        content: content,
        tagColor: tagColor,
        lastModified: DateTime.now(),
      );
      await repository.addNote(note);
      _notes = await repository.getNotes();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to add note: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      _isLoading = true;
      notifyListeners();
      await repository.updateNote(note);
      _notes = await repository.getNotes();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to update note: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await repository.deleteNote(id);
      _notes = await repository.getNotes();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to delete note: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}