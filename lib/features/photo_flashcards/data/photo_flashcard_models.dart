class PhotoFlashcardDeck {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int cardCount;

  const PhotoFlashcardDeck({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.cardCount,
  });
}

class PhotoFlashcard {
  final String itemId;
  final String termId;
  final String spanishText;
  final String koreanText;
  final String? imagePath;
  final String? imageAbsolutePath;
  final String? thumbnailPath;
  final String? thumbnailAbsolutePath;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PhotoFlashcard({
    required this.itemId,
    required this.termId,
    required this.spanishText,
    required this.koreanText,
    required this.imagePath,
    required this.imageAbsolutePath,
    required this.thumbnailPath,
    required this.thumbnailAbsolutePath,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });
}
