import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
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

class WatchListScreen extends StatefulWidget {
  WatchListScreen({
    super.key,
    required this.watchedList,
    required this.watchList,
  });
  Map<String, num> posterToId = {};
  final List<num> watchedList;
  final List<num> watchList;

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
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
      final movieIds = List<num>.from(userDoc.data()!['watchList']);

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

  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

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

  Future<void> removeMovie(num movieId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final documentId = currentUser.uid;
      final CollectionReference<Map<String, dynamic>> _collection =
          FirebaseFirestore.instance.collection('users');

      await _collection.doc(documentId).update({
        'watchedList': FieldValue.arrayRemove([movieId]),
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _data = Future.wait([
      fetchMoviePosters(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // if (auth.currentUser != null) {
    //   messagesStream();
    // }
    bool isDark = brightness == Brightness.dark;

    final movies;
    print(_posterURLs);
    final size = Utils(context).getScreenSize;
    //late String title = 'IamEmpty';
    return (auth.currentUser != null)
        ? Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.white,
            appBar: AppBar(
              backgroundColor: isDark ? Colors.black : Colors.blueAccent,
              title: Center(
                child: Text(
                  'YOUR WATCH LIST',
                  style: TextStyle(color: isDark ? Colors.white : Colors.white),
                ),
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
                      childAspectRatio: size.width / (size.height * 0.95),
                      children: List.generate(_posterURLs.length, (index) {
                        int reversedIndex = _posterURLs.length - 1 - index;
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
                              Row(
                                children: [
                                  SizedBox(width: 5),
                                  GFButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return RatingDialog(
                                            movieId: widget.posterToId[
                                                _posterURLs[reversedIndex]],
                                            watchedList: widget.watchedList,
                                            watchList: widget.watchList,
                                          );
                                        },
                                      );
                                    },
                                    text: "",
                                    color: GFColors.WARNING,
                                    icon: Icon(Icons.check_box),
                                    size: GFSize.SMALL,
                                  ),
                                  SizedBox(width: 10),
                                  GFButton(
                                    onPressed: () {
                                      removeMovie(widget.posterToId[
                                          _posterURLs[reversedIndex]]!);
                                      setState(() {
                                        _posterURLs
                                            .remove(_posterURLs[reversedIndex]);
                                      });
                                    },
                                    text: "",
                                    color: GFColors.DANGER,
                                    icon: Icon(Icons.delete_rounded,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black),
                                    type: GFButtonType.outline,
                                    size: GFSize.SMALL,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ));

                    //     child: ListView.builder(
                    //   scrollDirection: Axis.vertical,
                    //   itemCount: _posterURLs.length,
                    //   itemBuilder: (context, index) {
                    //     int reversedIndex = _posterURLs.length - 1 - index;
                    //     return InkWell(
                    //       onTap: () {
                    //         Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => MovieScreen(
                    //                 watchList: widget.watchList,
                    //                 watchedList: widget.watchedList,
                    //                 isTv: false,
                    //                 id: widget.posterToId[
                    //                     _posterURLs[reversedIndex]] as int?,
                    //               ),
                    //             ));
                    //       },
                    //       child: Column(
                    //         children: [
                    //           SizedBox(
                    //             height: 10,
                    //           ),
                    //           Image.network(
                    //             _posterURLs[reversedIndex],
                    //             width: 200,
                    //             height: 250,
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // ));
                  }
                }),
          )
        : Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.white,
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
                            color: isDark ? Colors.white : Colors.black,
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
                            color: isDark ? Colors.white : Colors.black,
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
