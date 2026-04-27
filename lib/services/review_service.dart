import 'db_helper.dart';
import 'package:midterm/models/review.dart';

class ReviewService {

  Future<int> insertReview(Review review) async {
    final db = await DBHelper.database;
    return await db.insert('reviews', review.toMap());
  }

  Future<List<Review>> getReviews() async {
    final db = await DBHelper.database;

    final maps = await db.query('reviews');

    return maps.map((e) => Review.fromMap(e)).toList();
  }

  Future<int> updateReview(Review review) async {
    final db = await DBHelper.database;
    return await db.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  Future<int> deleteReview(int id) async {
    final db = await DBHelper.database;
    return await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
