import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midterm/models/review.dart';
import 'package:midterm/services/notification_service.dart';
import 'package:midterm/services/firebase_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService firebaseService = FirebaseService();
  List<Review> reviews = [];
  String userName = "User";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    await loadUser();
    await loadReviews();
    setState(() => _isLoading = false);
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data() != null) {
      setState(() {
        userName = doc['name'] ?? "User";
      });
    }
  }

  Future<void> loadReviews() async {
    final data = await firebaseService.fetchReviews();
    setState(() {
      reviews = data;
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void showAddDialog() {
    final mangaController = TextEditingController();
    final commentController = TextEditingController();
    int tempRating = 3;
    File? tempImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Add New Review", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    TextField(
                      controller: mangaController,
                      decoration: InputDecoration(labelText: "Manga Title", prefixIcon: Icon(Icons.book)),
                    ),
                    SizedBox(height: 16),
                    Text("Rating", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < tempRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () => setDialogState(() => tempRating = index + 1),
                        );
                      }),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(labelText: "Your thoughts...", alignLabelWithHint: true),
                    ),
                    SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (picked != null) setDialogState(() => tempImage = File(picked.path));
                      },
                      icon: Icon(Icons.image),
                      label: Text(tempImage == null ? "Add Image" : "Change Image"),
                    ),
                    if (tempImage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(tempImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (mangaController.text.isEmpty) return;
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        final review = Review(
                          mangaId: mangaController.text.toLowerCase().replaceAll(' ', '_'),
                          mangaTitle: mangaController.text,
                          userId: user.uid,
                          rating: tempRating,
                          comment: commentController.text,
                          imagePath: tempImage?.path,
                        );

                        await firebaseService.uploadReview(review);
                        await NotificationService.showNotification(
                          "Review Added",
                          "Your review for ${review.mangaTitle} was saved ⭐",
                        );

                        Navigator.pop(context);
                        loadReviews();
                      },
                      child: Text("Submit Review"),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showEditDialog(Review review) {
    final mangaCtrl = TextEditingController(text: review.mangaTitle);
    final commentCtrl = TextEditingController(text: review.comment);
    int tempRating = review.rating;
    File? tempImage = review.imagePath != null ? File(review.imagePath!) : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("Edit Review", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    TextField(
                      controller: mangaCtrl,
                      decoration: InputDecoration(labelText: "Manga Title", prefixIcon: Icon(Icons.book)),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < tempRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () => setDialogState(() => tempRating = index + 1),
                        );
                      }),
                    ),
                    TextField(
                      controller: commentCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(labelText: "Review", alignLabelWithHint: true),
                    ),
                    SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (picked != null) setDialogState(() => tempImage = File(picked.path));
                      },
                      icon: Icon(Icons.image),
                      label: Text("Change Image"),
                    ),
                    if (tempImage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(tempImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        review.mangaTitle = mangaCtrl.text;
                        review.comment = commentCtrl.text;
                        review.rating = tempRating;
                        review.imagePath = tempImage?.path;

                        await firebaseService.updateReview(review);
                        Navigator.pop(context);
                        loadReviews();
                      },
                      child: Text("Update Review"),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manga Reviews", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Hi, $userName", style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: loadReviews),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        label: Text("Add Review"),
        icon: Icon(Icons.add),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.library_books_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No reviews yet. Be the first to add one!", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadReviews,
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: reviews.length,
                    itemBuilder: (_, i) {
                      final r = reviews[i];
                      final isOwner = r.userId == currentUser?.uid;

                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (r.imagePath != null && r.imagePath!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.file(
                                  File(r.imagePath!),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r.mangaTitle,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      if (isOwner)
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                              onPressed: () => showEditDialog(r),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: Text("Delete Review?"),
                                                    content: Text("Are you sure you want to delete this review?"),
                                                    actions: [
                                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel")),
                                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Delete", style: TextStyle(color: Colors.red))),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await firebaseService.deleteReview(r.docId!);
                                                  loadReviews();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => Icon(
                                        index < r.rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    r.comment,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}