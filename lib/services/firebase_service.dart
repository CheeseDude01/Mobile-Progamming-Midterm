import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:midterm/models/review.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Future<void> uploadReview(Review review) async {
    await _db.collection('reviews').add({
      'mangaId': review.mangaId,
      'mangaTitle': review.mangaTitle,
      'userId': review.userId,
      'rating': review.rating,
      'comment': review.comment,
      'imagePath': review.imagePath,
      'createdAt': Timestamp.now(),
    });
  }

  Future<List<Review>> fetchReviews() async {
    final snapshot = await _db.collection('reviews').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Review(
        docId: doc.id,
        mangaId: data['mangaId'],
        mangaTitle: data['mangaTitle'] ?? "",
        userId: data['userId'],
        rating: data['rating'],
        comment: data['comment'],
        imagePath: data['imagePath'],
      );
    }).toList();
  }

  Future<void> deleteReview(String docId) async {
    await _db.collection('reviews').doc(docId).delete();
  }

  Future<void> updateReview(Review review) async {
    await _db.collection('reviews').doc(review.docId).update({
      'mangaTitle': review.mangaTitle,
      'rating': review.rating,
      'comment': review.comment,
      'imagePath': review.imagePath,
    });
  }
}

