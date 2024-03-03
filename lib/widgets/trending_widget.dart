import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:showtime/screens/movie_screen.dart';
import 'package:showtime/widgets/ratingAlert.dart';
import 'package:showtime/widgets/ratingAlertHome.dart';

import '../services/global_methods.dart';
import '../services/utils.dart';

class TrendingWidget extends StatefulWidget {
  final String posterPath;
  final String title;
  final int? movieId;
  late bool isAddedToWatchList;
  late bool alreadyWatched;
  final bool isTV;
  final List<num> watchedList;
  final List<num> watchList;
  TrendingWidget({
    required this.posterPath,
    required this.movieId,
    required this.title,
    required this.isTV,
    required this.watchedList,
    required this.watchList,
  });
  @override
  State<TrendingWidget> createState() => _TrendingWidgetState();
}

class _TrendingWidgetState extends State<TrendingWidget> {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');
  FirebaseAuth auth = FirebaseAuth.instance;
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  void addItemToArray(String arrayName, int? movieId) async {
    final documentId = auth.currentUser?.uid;
    final itemToAdd = movieId;

    await _collection.doc(documentId).update({
      '$arrayName': FieldValue.arrayUnion([itemToAdd])
    });
  }

  void removeItemFromArray(String arrayName, int? movieId) async {
    final documentId = auth.currentUser?.uid;
    final itemToAdd = movieId;

    await _collection.doc(documentId).update({
      '$arrayName': FieldValue.arrayRemove([itemToAdd])
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      widget.isAddedToWatchList = widget.watchList.contains(widget.movieId);
      widget.alreadyWatched = widget.watchedList.contains(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    bool isDarkMode = brightness == Brightness.dark;
    return Material(
      color: isDarkMode ? Colors.black : Colors.white,
      child: InkWell(
          onTap: () {
            print(widget.movieId);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieScreen(
                    isTv: widget.isTV,
                    id: widget.movieId,
                    watchedList: widget.watchedList,
                    watchList: widget.watchList,
                  ),
                ));
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.posterPath,
                      height: 200,
                      width: 130,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(width: 35),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (widget.isAddedToWatchList == true) {
                            removeItemFromArray('watchList', widget.movieId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Removed from WatchList'),
                                duration: Duration(milliseconds: 800),
                              ),
                            );
                          } else {
                            if (widget.isAddedToWatchList == false) {
                              addItemToArray('watchList', widget.movieId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added to WatchList'),
                                  duration: Duration(milliseconds: 800),
                                ),
                              );
                            }
                          }

                          widget.isAddedToWatchList =
                              !widget.isAddedToWatchList;
                        });
                      },
                      child: widget.isAddedToWatchList == true
                          ? FaIcon(
                              FontAwesomeIcons.solidBookmark,
                              size: 30,
                              color: isDarkMode ? Colors.white : Colors.black,
                            )
                          : FaIcon(
                              FontAwesomeIcons.bookmark,
                              size: 30,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          addItemToArray('watchedList', widget.movieId);
                          if (widget.alreadyWatched == true) {
                            removeItemFromArray('watchedList', widget.movieId);
                          } else {
                            if (widget.alreadyWatched == false) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return RatingDialogHome(
                                      movieId: widget.movieId,
                                      watchedList: widget.watchedList,
                                      watchList: widget.watchList,
                                    );
                                  });
                            }
                          }

                          widget.alreadyWatched = !widget.alreadyWatched;
                        });
                      },
                      child: widget.alreadyWatched == true
                          ? FaIcon(
                              FontAwesomeIcons.solidSquareCheck,
                              size: 30,
                              color: isDarkMode ? Colors.white : Colors.black,
                            )
                          : FaIcon(
                              FontAwesomeIcons.squareCheck,
                              size: 30,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}

class BrowseAllWidget extends StatefulWidget {
  final String posterPath;
  final String title;
  late int? movieId;
  late bool isAddedToWatchList = false;
  late bool alreadyWatched = false;
  final bool isTV;
  final List<num> watchedList;
  final List<num> watchList;

  BrowseAllWidget(
      {required this.posterPath,
      required this.movieId,
      required this.title,
      required this.isTV,
      required this.watchedList,
      required this.watchList});

  @override
  State<BrowseAllWidget> createState() => _BrowseAllWidgetState();
}

class _BrowseAllWidgetState extends State<BrowseAllWidget> {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');
  FirebaseAuth auth = FirebaseAuth.instance;
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  void addItemToArray(String arrayName, int? movieId) async {
    final documentId = auth.currentUser?.uid;
    final itemToAdd = movieId;

    await _collection.doc(documentId).update({
      '$arrayName': FieldValue.arrayUnion([itemToAdd])
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    setState(() {
      widget.isAddedToWatchList = widget.watchList.contains(widget.movieId);
      widget.alreadyWatched = widget.watchedList.contains(widget.movieId);
    });
  }

  void removeItemFromArray(String arrayName, int? movieId) async {
    final documentId = auth.currentUser?.uid;
    final itemToAdd = movieId;

    await _collection.doc(documentId).update({
      '$arrayName': FieldValue.arrayRemove([itemToAdd])
    });
  }

  @override
  Widget build(BuildContext context) {
    print('${widget.movieId} : ${widget.isAddedToWatchList}');
    Size size = Utils(context).getScreenSize;
    bool isDarkMode = brightness == Brightness.dark;
    // setState(() {
    //   widget.isAddedToWatchList =
    //       widget.watchList.contains(widget.movieId) ? true : false;
    //   widget.alreadyWatched =
    //       widget.watchedList.contains(widget.movieId) ? true : false;
    // });
    return Material(
      color: isDarkMode ? Colors.black : Colors.white,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieScreen(
                    isTv: widget.isTV,
                    id: widget.movieId,
                    watchedList: widget.watchedList,
                    watchList: widget.watchList,
                  ),
                ));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.posterPath,
                      // height: 200,
                      // width: 130,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(width: 25),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (widget.isAddedToWatchList == true) {
                          removeItemFromArray('watchList', widget.movieId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed From WatchList'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          if (widget.isAddedToWatchList == false) {
                            addItemToArray('watchList', widget.movieId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added to WatchList'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        }

                        widget.isAddedToWatchList = !widget.isAddedToWatchList;
                      });
                    },
                    child: widget.isAddedToWatchList == true
                        ? FaIcon(
                            FontAwesomeIcons.solidBookmark,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.black,
                          )
                        : FaIcon(
                            FontAwesomeIcons.bookmark,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        addItemToArray('watchedList', widget.movieId);
                        if (widget.alreadyWatched == true) {
                          removeItemFromArray('watchedList', widget.movieId);
                        } else {
                          if (widget.alreadyWatched == false) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return RatingDialogHome(
                                    movieId: widget.movieId,
                                    watchedList: widget.watchedList,
                                    watchList: widget.watchList,
                                  );
                                });
                          }
                        }

                        widget.alreadyWatched = !widget.alreadyWatched;
                      });
                    },
                    child: widget.alreadyWatched == true
                        ? FaIcon(
                            FontAwesomeIcons.solidSquareCheck,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.black,
                          )
                        : FaIcon(
                            FontAwesomeIcons.squareCheck,
                            size: 30,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                  )
                ],
              )
            ],
          )),
    );
  }
}
