import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom_and_note_app/feature/notes/data/models/note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repository/note_repository_impl.dart';
import '../provider/note_provider.dart';
import 'note_list_screen.dart';

class NoteEditScreen extends StatefulWidget {
  final NoteModel? note;

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedTagColor = 'grey';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedTagColor = widget.note?.tagColor ?? 'grey';
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      if (widget.note == null) {
        noteProvider.addNote(
          _titleController.text,
          _contentController.text,
          _selectedTagColor,
        );
      } else {
        noteProvider.updateNote(
          NoteModel(
            id: widget.note!.id,
            title: _titleController.text,
            content: _contentController.text,
            tagColor: _selectedTagColor,
            isSynced: widget.note!.isSynced,
            lastModified: DateTime.now(),
          ),
        );
      }

      final prefs = await SharedPreferences.getInstance();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => NoteProvider(repository: NoteRepositoryImpl(prefs))..loadNotes(),
            child: const NoteListScreen(),
          ),

        ),
      );


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Provider.of<NoteProvider>(context, listen: false)
                    .deleteNote(widget.note!.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 5,
                validator: (value) =>
                value!.isEmpty ? 'Please enter content' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTagColor,
                decoration: const InputDecoration(labelText: 'Tag Color'),
                items: [
                  DropdownMenuItem(value: 'grey', child: Text('Grey')),
                  DropdownMenuItem(value: 'red', child: Text('Red')),
                  DropdownMenuItem(value: 'blue', child: Text('Blue')),
                  DropdownMenuItem(value: 'green', child: Text('Green')),
                ],
                onChanged: (value) => setState(() => _selectedTagColor = value!),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.note == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}