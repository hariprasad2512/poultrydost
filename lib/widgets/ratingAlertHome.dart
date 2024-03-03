import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:showtime/screens/bottom_bar.dart';
import 'package:showtime/screens/movie_screen.dart';

import '../screens/watchList.dart';

class RatingDialogHome extends StatefulWidget {
  final num? movieId;
  final List<num> watchedList;
  final List<num> watchList;

  RatingDialogHome({
    required this.movieId,
    required this.watchedList,
    required this.watchList,
  });

  @override
  _RatingDialogHomeState createState() => _RatingDialogHomeState();
}

class _RatingDialogHomeState extends State<RatingDialogHome> {
  double _rating = 0.0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addRatingToFirestore() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final documentId = currentUser.uid;
      final ratingData = {'${widget.movieId}': _rating};
      await _collection.doc(documentId).update({
        'ratings': FieldValue.arrayUnion([ratingData]),
        'watchedList': FieldValue.arrayUnion([widget.movieId]),
        'watchList': FieldValue.arrayRemove([widget.movieId])
      });
    }
  }

  Future<void> addnewRatingToFirestore() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final documentId = currentUser.uid;
      final userDocument = await _collection.doc(documentId).get();
      final existingRatings = userDocument.data()?['ratings'];

      final newRatingData = {'${widget.movieId}': _rating};

      if (existingRatings != null && existingRatings is Map) {
        // If the ratings exist and are a map, update the existing rating data
        final movieId = widget.movieId.toString();
        await _collection.doc(documentId).update({
          'ratings.$movieId': _rating,
          'watchedList': FieldValue.arrayUnion([widget.movieId]),
          'watchList': FieldValue.arrayRemove([widget.movieId])
        });
      } else {
        // If there are no ratings data or the data is not a map, add the new rating data
        await _collection.doc(documentId).update({
          'ratings': FieldValue.arrayUnion([newRatingData]),
          'watchedList': FieldValue.arrayUnion([widget.movieId]),
          'watchList': FieldValue.arrayRemove([widget.movieId])
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate the Movie'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Please rate the movie:',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 40,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Skip'),
        ),
        ElevatedButton(
          onPressed: () async {
            await addnewRatingToFirestore();
            Navigator.pop(context);
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
