import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/types/gf_button_type.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showtime/common/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:showtime/screens/splashScreen.dart';
import 'package:showtime/services/utils.dart';
import '../widgets/ratingAlert.dart';
import '../widgets/trending_widget.dart';
import 'movie_screen.dart';

User? loggedInUser;

class WatchedListScreen extends StatefulWidget {
  WatchedListScreen({
    super.key,
    required this.watchedList,
    required this.watchList,
  });
  Map<String, num> posterToId = {};
  final List<num> watchedList;
  final List<num> watchList;
  Map<num, double> idToRating = {};

  @override
  State<WatchedListScreen> createState() => _WatchedListScreenState();
}

class _WatchedListScreenState extends State<WatchedListScreen> {
  late final Future<List<void>> _data;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final idToPoster = {};
  final _firestore = FirebaseFirestore.instance;

  Future<bool> tvOrNot(num mediaId) async {
    final apiKey = APIConstants.API_KEY;
    final movieUrl =
        'https://api.themoviedb.org/3/movie/$mediaId?api_key=$apiKey';
    final tvUrl = 'https://api.themoviedb.org/3/tv/$mediaId?api_key=$apiKey';

    try {
      final movieResponse = await http.get(Uri.parse(movieUrl));
      final tvResponse = await http.get(Uri.parse(tvUrl));

      final movieData = json.decode(movieResponse.body);
      final tvData = json.decode(tvResponse.body);

      if (movieData.containsKey('id')) {
        return false;
      } else if (tvData.containsKey('id')) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  final movieTitles = [];
  List<String> _posterURLs = [];

  Future<List<String>> getMoviePosterURLs(String uid) async {
    try {
      // Get user document by UID
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }

      // Get movie IDs array from user document
      final movieIds = List<num>.from(userDoc.data()!['watchedList']);

      // Array to store movie poster URLs
      final posterURLs = <String>[];

      // Fetch movie details and poster URLs
      for (final movieId in movieIds) {
        final response = await http.get(
          Uri.parse(
            'https://api.themoviedb.org/3/movie/$movieId?api_key=${APIConstants.API_KEY}',
          ),
        );

        if (response.statusCode == 200) {
          final posterPath = jsonDecode(response.body)['poster_path'];
          if (posterPath != null) {
            final posterURL = 'https://image.tmdb.org/t/p/w500$posterPath';
            posterURLs.add(posterURL);
            widget.posterToId[posterURL] = movieId;
            idToPoster[movieId] = posterURL;
          }
        } else {
          throw Exception('Failed to fetch movie details');
        }
      }

      return posterURLs;
    } catch (error) {
      print('Error retrieving movie poster URLs: $error');
      rethrow;
    }
  }

  Future<void> fetchMoviePosters() async {
    try {
      final posterURLs =
          await getMoviePosterURLs(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        _posterURLs = posterURLs;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getUserRating(num mvId) async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final documentId = currentUser.uid;
      final userDocument = await _collection.doc(documentId).get();
      final ratings = userDocument.data()?['ratings'];

      if (ratings != null && ratings is Map) {
        final movieId = mvId.toString();
        final userRating = ratings[movieId];
        if (userRating != null) {
          setState(() {
            widget.idToRating[mvId] = userRating.toDouble();
          });
        } else {
          // If the user has not rated the movie, set the rating to 0
          setState(() {
            widget.idToRating[mvId] = 0.0;
          });
        }
      }
    }
  }

  void getMoviesRating(List<String> posterURLs) {
    for (String poster in posterURLs) {
      num movieID = widget.posterToId[poster]!;
      getUserRating(movieID);
    }
  }

  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();
    _data = Future.wait([
      fetchMoviePosters(),
    ]);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');

  Future<void> removeMovie(num movieId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final documentId = currentUser.uid;

      await _collection.doc(documentId).update({
        'watchedList': FieldValue.arrayRemove([movieId]),
      });
    }
  }

  Future<void> addnewRatingToFirestore(num _movieId, double _rating) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final documentId = currentUser.uid;
      final userDocument = await _collection.doc(documentId).get();
      final existingRatings = userDocument.data()?['ratings'];

      final newRatingData = {'${_movieId}': _rating};

      if (existingRatings != null && existingRatings is Map) {
        // If the ratings exist and are a map, update the existing rating data
        final movieId = _movieId.toString();
        await _collection.doc(documentId).update({
          'ratings.$movieId': _rating,
          'watchedList': FieldValue.arrayUnion([_movieId]),
          'watchList': FieldValue.arrayRemove([_movieId])
        });
      } else {
        // If there are no ratings data or the data is not a map, add the new rating data
        await _collection.doc(documentId).update({
          'ratings': newRatingData,
          'watchedList': FieldValue.arrayUnion([_movieId]),
          'watchList': FieldValue.arrayRemove([_movieId])
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getMoviesRating(_posterURLs);
    bool isDark = brightness == Brightness.dark;

    final size = Utils(context).getScreenSize;

    return (auth.currentUser != null)
        ? Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.white,
            appBar: AppBar(
              backgroundColor: isDark ? Colors.black : Colors.blueAccent,
              title: Center(
                child: Text('Movie Tracker',
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black)),
              ),
            ),
            body: FutureBuilder(
                future: _data,
                builder:
                    (BuildContext context, AsyncSnapshot<List<void>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Splash();
                  } else {
                    return SafeArea(
                        child: GridView.count(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      padding: EdgeInsets.zero,
                      childAspectRatio: size.width / (size.height * 1.1),
                      children: List.generate(_posterURLs.length, (index) {
                        int reversedIndex = _posterURLs.length - 1 - index;
                        num mvID =
                            widget.posterToId[_posterURLs[reversedIndex]]!;
                        double? ratingOfMovie = widget.idToRating[mvID];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MovieScreen(
                                    watchList: widget.watchList,
                                    watchedList: widget.watchedList,
                                    isTv: false,
                                    id: widget.posterToId[
                                        _posterURLs[reversedIndex]] as int?,
                                  ),
                                ));
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Image.network(
                                _posterURLs[reversedIndex],
                                width: 200,
                                height: 250,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                  child: RatingBar.builder(
                                initialRating: ratingOfMovie ?? 0,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 25,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                ignoreGestures: false,
                                onRatingUpdate: (rating) async {
                                  setState(() {
                                    ratingOfMovie = rating;
                                  });
                                  await addnewRatingToFirestore(
                                      mvID, ratingOfMovie!);
                                },
                              )),
                              GFButton(
                                onPressed: () {
                                  removeMovie(widget
                                      .posterToId[_posterURLs[reversedIndex]]!);
                                  setState(() {
                                    _posterURLs
                                        .remove(_posterURLs[reversedIndex]);
                                  });
                                },
                                text: "Delete",
                                color: GFColors.DANGER,
                                icon: Icon(Icons.delete_rounded,
                                    color:
                                        isDark ? Colors.white : Colors.black),
                                type: GFButtonType.outline,
                              ),
                            ],
                          ),
                        );
                      }),
                    ));
                  }
                }),
          )
        : Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      SizedBox(width: 25),
                      SizedBox(
                        width: 300,
                        child: Center(
                            child: Text(
                          "Uh..Oh! ",
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      SizedBox(width: 25),
                      SizedBox(
                        width: 300,
                        child: Center(
                            child: Text(
                          "Please Sign In to use WatchList",
                          style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, 'phone', (route) => false);
                    },
                    child: Text('Sign In'))
              ],
            ),
          );
  }
}
