class Review {
  int? id;
  String? docId;
  String mangaId;
  String mangaTitle;
  String userId;
  int rating;
  String comment;
  String? imagePath;

  Review({
    this.id,
    this.docId,
    required this.mangaId,
    required this.mangaTitle,
    required this.userId,
    required this.rating,
    required this.comment,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mangaId': mangaId,
      'mangaTitle': mangaTitle,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'imagePath': imagePath,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      mangaId: map['mangaId'],
      mangaTitle: map['mangaTitle'],
      userId: map['userId'],
      rating: map['rating'],
      comment: map['comment'],
      imagePath: map['imagePath'],
    );
  }
}