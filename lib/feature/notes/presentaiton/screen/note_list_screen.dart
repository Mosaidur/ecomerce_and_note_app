import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme provider/themeProvider.dart';
import '../provider/note_provider.dart';
import 'note_edit_screen.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final noteProvider = Provider.of<NoteProvider>(context);
    print('NoteProvider in NoteListScreen: $noteProvider'); // Debug

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: noteProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : noteProvider.errorMessage != null
          ? Center(child: Text(noteProvider.errorMessage!))
          : noteProvider.notes.isEmpty
          ? const Center(child: Text('No notes yet. Add one!'))
          : ListView.builder(
        itemCount: noteProvider.notes.length,
        itemBuilder: (context, index) {
          final note = noteProvider.notes[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTagColor(note.tagColor),
            ),
            title: Text(note.title),
            subtitle: Text(
              note.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => noteProvider.deleteNote(note.id),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoteEditScreen(note: note),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoteEditScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getTagColor(String tagColor) {
    switch (tagColor) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}