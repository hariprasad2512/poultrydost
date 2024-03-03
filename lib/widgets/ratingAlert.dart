import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:showtime/screens/bottom_bar.dart';

import '../screens/watchList.dart';

class RatingDialog extends StatefulWidget {
  final num? movieId;
  final List<num> watchedList;
  final List<num> watchList;

  RatingDialog(
      {required this.movieId,
      required this.watchedList,
      required this.watchList});

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0.0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

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
          'ratings': newRatingData,
          'watchedList': FieldValue.arrayUnion([widget.movieId]),
          'watchList': FieldValue.arrayRemove([widget.movieId])
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? Colors.black : Colors.white,
      title: Text(
        'Rate the Movie',
        style: TextStyle(color: isDark ? Colors.white : Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Please rate the movie:',
            style: TextStyle(
                fontSize: 16, color: isDark ? Colors.white : Colors.black),
          ),
          SizedBox(height: 20),
          RatingBar.builder(
            initialRating: _rating,
            unratedColor: isDark ? Colors.white60 : Colors.grey,
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
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await addnewRatingToFirestore();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => BottomBarScreen(
                          watchedList: widget.watchedList,
                          watchList: widget.watchList,
                          selectedIndex: 2,
                        )),
                (route) => false);
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
