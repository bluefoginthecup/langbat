import '../db/app_database.dart';

class LocalTerm {
  final String id;
  final String type;
  final String frontText;
  final String backText;
  final String note;
  final String frontLanguage;
  final String backLanguage;
  final String? imagePath;
  final String? audioFrontPath;
  final String? audioBackPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LocalTerm({
    required this.id,
    required this.type,
    required this.frontText,
    required this.backText,
    required this.note,
    required this.frontLanguage,
    required this.backLanguage,
    this.imagePath,
    this.audioFrontPath,
    this.audioBackPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocalTerm.fromRow(Term row) {
    return LocalTerm(
      id: row.id,
      type: row.type,
      frontText: row.frontText,
      backText: row.backText,
      note: row.note,
      frontLanguage: row.frontLanguage,
      backLanguage: row.backLanguage,
      imagePath: row.imagePath,
      audioFrontPath: row.audioFrontPath,
      audioBackPath: row.audioBackPath,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
    );
  }
}

class LocalFlashcardSet {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemCount;

  const LocalFlashcardSet({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.itemCount,
  });
}

class LocalFlashcard {
  final String id;
  final String termId;
  final String text;
  final String meaning;
  final int order;
  final String imageUrl;

  const LocalFlashcard({
    required this.id,
    required this.termId,
    required this.text,
    required this.meaning,
    required this.order,
    this.imageUrl = '',
  });

  Map<String, dynamic> toStudyMap() {
    return {
      'id': id,
      'termId': termId,
      'text': text,
      'meaning': meaning,
      'order': order,
      'imageUrl': imageUrl,
    };
  }
}
