import 'dart:convert';

class NoteModel {
  String id;
  String title;
  String content;
  String tagColor;
  bool isSynced;
  DateTime lastModified;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tagColor,
    this.isSynced = false,
    required this.lastModified,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'tagColor': tagColor,
    'isSynced': isSynced,
    'lastModified': lastModified.toIso8601String(),
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    tagColor: json['tagColor'],
    isSynced: json['isSynced'],
    lastModified: DateTime.parse(json['lastModified']),
  );
}