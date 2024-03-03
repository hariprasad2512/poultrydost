import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showtime/screens/splashScreen.dart';
import 'package:showtime/widgets/cast_widget.dart';
import 'package:shadow_overlay/shadow_overlay.dart';
import 'package:showtime/common/api_constants.dart';
import 'package:showtime/widgets/ratingAlertMovie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/api_client.dart';
import '../data/movie_remote_data_source.dart';
import 'package:http/http.dart';

import '../services/movieDetails.dart';
import '../services/utils.dart';
import '../widgets/ratingAlert.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:flutter_animated_icons/lottiefiles.dart';
import 'package:flutter_animated_icons/useanimations.dart';
import 'package:lottie/lottie.dart';

class MovieScreen extends StatefulWidget {
  MovieScreen({
    required this.isTv,
    required this.id,
    required this.watchedList,
    required this.watchList,
  });
  final int? id;
  late String? posterURL = 'I am empty';
  final bool isTv;
  late String? movieName = '';
  late String? synopsis = '';
  late String? moviePoster = '';
  late bool isAddedToWatchList;
  late String? year = '';
  late String? homePage = '';
  late String? directorName = '';
  late double ImdbRating = 0;
  late String? imdbId = '';
  final List<num> watchedList;
  final List<num> watchList;
  late List<Map<String, dynamic>>? castDetails = [];
  late List<Map<String, dynamic>>? crewDetails = [];

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen>
    with TickerProviderStateMixin {
  late final Future<List<void>> _data;
  late bool ratingExists = false;
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');
  FirebaseAuth auth = FirebaseAuth.instance;
  double _rating = 0.0;
  late AnimationController _favoriteController;
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

  Future<void> getDirectorName(int? movieId) async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);
    widget.directorName =
        await dataSource.getDirectorName(movieId!, widget.isTv);
  }

  Future<void> getMovieInfo(int? movieId) async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);

    if (!widget.isTv) {
      final movie = await dataSource.getMovieDetailsById(movieId!);
      setState(() {
        widget.posterURL = movie.backdropPath;
        widget.movieName = movie.title!;
        widget.synopsis = movie.overview;
        widget.moviePoster = movie.posterPath;
        widget.homePage = movie.homepage;
        widget.year = movie.releaseDate?.substring(0, 4);
        widget.imdbId = movie.imdbId;
      });
    } else {
      final tvSeries = await dataSource.getTVDetailsById(movieId!);
      setState(() {
        widget.posterURL = tvSeries.backdropPath;
        widget.movieName = tvSeries.name;
        widget.synopsis = tvSeries.overview;
        widget.moviePoster = tvSeries.posterPath;
        widget.year = tvSeries.releaseDate;
        widget.homePage = tvSeries.homepage;
      });
    }
  }

  Future<void> getCastDetails(int? movieId) async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);
    widget.castDetails = await dataSource.fetchMovieCast(movieId!, widget.isTv);
  }

  Future<void> getCrewDetails(int? movieId) async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);
    widget.crewDetails = await dataSource.fetchMovieCrew(movieId!, widget.isTv);
  }

  Future<bool> checkRatingExists() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final documentId = currentUser.uid;
      final userDocument = await _collection.doc(documentId).get();

      if (userDocument.exists) {
        final ratings = userDocument.data()?['ratings'];
        if (ratings != null) {
          final movieId = widget.id.toString();
          return ratings.containsKey(movieId);
        }
      }
    }

    return false;
  }

  void checkrating() async {
    ratingExists = await checkRatingExists();
  }

  Future<void> connectFirebase() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      //   final documentId = auth.currentUser?.uid;
      //   final snapshot = await _collection.doc(auth.currentUser?.uid).get();
      //   if (snapshot.exists) {
      //     final data = snapshot.data();
      //     final arrayField = data!['watchedList'] as List<num>;
      //     final arrayField2 = data!['watchList'] as List<num>;
      //     watchedList = arrayField;
      //     watchList = arrayField2;
      //   }

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        // User already exists in Firestore, retrieve watchedList and watchList arrays
        final userData = userSnapshot.data() as Map<String, dynamic>;
        widget.watchedList
            .addAll((userData['watchedList'] as List<dynamic>).cast<num>());
        widget.watchList
            .addAll((userData['watchList'] as List<dynamic>).cast<num>());
      }
    }
  }

  Future<void> getUserRating() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final documentId = currentUser.uid;
      final userDocument = await _collection.doc(documentId).get();
      final ratings = userDocument.data()?['ratings'];

      if (ratings != null && ratings is Map) {
        final movieId = widget.id.toString();
        final userRating = ratings[movieId];
        if (userRating != null) {
          setState(() {
            _rating = userRating.toDouble();
          });
        } else {
          // If the user has not rated the movie, set the rating to 0
          setState(() {
            _rating = 0.0;
          });
        }
      }
    }
  }

  Future<void> addRatingToFirestore() async {
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      final documentId = currentUser.uid;
      final ratingData = {'${widget.id}': _rating};
      await _collection.doc(documentId).update({
        'ratings': FieldValue.arrayUnion([ratingData]),
        'watchedList': FieldValue.arrayUnion([widget.id]),
        'watchList': FieldValue.arrayRemove([widget.id])
      });
    }
  }

  var countOfCrew = 0;
  @override
  void initState() {
    // TODO: implement initState
    _favoriteController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    setState(() {
      widget.isAddedToWatchList = widget.watchList.contains(widget.id);
    });
    print(widget.watchList);
    _data = Future.wait<void>([
      getMovieInfo(widget.id),
      getDirectorName(widget.id),
      getCastDetails(widget.id),
      getCrewDetails(widget.id),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final size = Utils(context).getScreenSize;
    var websiteURI = Uri.parse(widget.homePage!);
    for (int i = 0; i < widget.crewDetails!.length; i++) {
      var crew = widget.crewDetails?[i];
      if (crew?['profile_path'] != null) {
        countOfCrew++;
      }
    }

    setState(() {
      checkrating();
    });

    String posterURL = '${APIConstants.baseImageURL}${widget.posterURL}';
    String moviePosterURL = '${APIConstants.baseImageURL}${widget.moviePoster}';
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 20, top: 15),
              child: FaIcon(
                FontAwesomeIcons.chevronLeft,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          actions: [
            // InkWell(
            //   onTap: () {},
            //   child: IconButton(
            //     splashRadius: 50,
            //     iconSize: 100,
            //     onPressed: () {
            //       if (_favoriteController.status == AnimationStatus.dismissed) {
            //         _favoriteController.reset();
            //         _favoriteController.animateTo(0.6);
            //       } else {
            //         _favoriteController.reverse();
            //       }
            //     },
            //     icon: Lottie.asset(Icons8.heart_color,
            //         controller: _favoriteController),
            //   ),
            // ),
            InkWell(
              onTap: () {
                setState(() {
                  if (widget.isAddedToWatchList == true) {
                    removeItemFromArray('watchList', widget.id);
                  } else {
                    if (widget.isAddedToWatchList == false) {
                      addItemToArray('watchList', widget.id);
                    }
                  }
                  widget.isAddedToWatchList = !widget.isAddedToWatchList;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(right: 20, top: 15),
                child: widget.isAddedToWatchList == true
                    ? const FaIcon(
                        FontAwesomeIcons.solidBookmark,
                        size: 25,
                      )
                    : const FaIcon(
                        FontAwesomeIcons.bookmark,
                        size: 25,
                      ),
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<void>>(
            future: _data,
            builder:
                (BuildContext context, AsyncSnapshot<List<void>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Splash();
              } else {
                getUserRating();
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Stack(
                    children: [
                      ShadowOverlay(
                          shadowHeight: 230,
                          shadowWidth: 420,
                          shadowColor: Colors.black,
                          child: Center(
                            child: Image.network(
                              posterURL,
                              fit: BoxFit.cover,
                              height: 400,
                            ),
                          )),
                      Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 300,
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: SizedBox(
                                      width: 20,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 13,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.movieName!,
                                          style: GoogleFonts.playfairDisplay(
                                              fontSize: 33,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              widget.year ?? "",
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                fontSize: 23,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Center(
                                              child: (widget.homePage!) != ''
                                                  ? ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.white),
                                                      onPressed: () async {
                                                        var url =
                                                            widget.homePage;

                                                        if (await canLaunchUrl(
                                                            Uri.parse(url!))) {
                                                          await launchUrl(
                                                              Uri.parse(url),
                                                              mode: LaunchMode
                                                                  .externalApplication);
                                                        } else {
                                                          throw 'Could not launch $url';
                                                        }
                                                      },
                                                      child: Text(
                                                        'WATCH NOW',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 10),
                                                      ),
                                                    )
                                                  : Container(),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: SizedBox(
                                      width: 20,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 10,
                                    child: Image.network(
                                      moviePosterURL,
                                      height: 250,
                                      width: 150,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 20),
                                      Text(
                                        'Synopsis',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 28,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(height: 15),
                                      Row(
                                        children: [
                                          SizedBox(width: 20),
                                          SizedBox(
                                            width: 330,
                                            child: Text(
                                              widget.synopsis!,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      SizedBox(width: 20),
                                      Text(
                                        'Directed By',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 28,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      SizedBox(
                                        width: 190,
                                        child: Text(widget.directorName ?? "",
                                            style: GoogleFonts.playfairDisplay(
                                              fontSize: 28,
                                              color: Colors.white,
                                            )),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text('Cast',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 28,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    height: size.height * 0.45,
                                    child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: 6,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (ctx, index) {
                                          var castMember =
                                              widget.castDetails?[index];
                                          var castName = castMember?['name'];
                                          var character =
                                              castMember?['character'];
                                          var personID = castMember?['id'];
                                          var profileURL =
                                              '${APIConstants.baseImageURL}${castMember?['profile_path']}';
                                          return CastWidget(
                                            posterPath: profileURL,
                                            actorName: castName,
                                            character: character,
                                            personId: personID,
                                            castOrNot: true,
                                            watchedList: widget.watchedList,
                                            watchList: widget.watchList,
                                          );
                                        }),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text((countOfCrew != 0) ? 'Crew' : '',
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 28,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                  SizedBox(height: (countOfCrew != 0) ? 10 : 0),
                                  SizedBox(
                                    height: (countOfCrew != 0)
                                        ? size.height * 0.47
                                        : 0,
                                    child: (countOfCrew != 0)
                                        ? ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            itemCount: 8,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (ctx, index) {
                                              var crewMember =
                                                  widget.crewDetails?[index];
                                              var crewName =
                                                  crewMember?['name'];
                                              var crewID = crewMember?['id'];
                                              var crewJob = crewMember!['job'];
                                              var url =
                                                  crewMember['profile_path'];
                                              var profileURL =
                                                  '${APIConstants.baseImageURL}${crewMember['profile_path']}';

                                              if (crewMember['profile_path'] ==
                                                  null) {
                                                return Container();
                                              }
                                              // 'https://www.iconspng.com/images/generic-male-avatar-rectangular/generic-male-avatar-rectangular.jpg';

                                              return CastWidget(
                                                posterPath: profileURL,
                                                actorName: crewName,
                                                character: crewJob,
                                                personId: crewID,
                                                castOrNot: false,
                                                watchedList: widget.watchedList,
                                                watchList: widget.watchList,
                                              );
                                            })
                                        : Container(),
                                  ),
                                  SizedBox(height: 5),
                                  SizedBox(
                                    child: (ratingExists == false)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                                Icon(
                                                  Icons.star_outline_rounded,
                                                  size: 30,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 5),
                                                TextButton(
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return RatingDialogMovie(
                                                                isTV:
                                                                    widget.isTv,
                                                                movieId:
                                                                    widget.id,
                                                                watchedList: widget
                                                                    .watchedList,
                                                                watchList: widget
                                                                    .watchList);
                                                          });
                                                    },
                                                    child: Text("Rate",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.white,
                                                        ))),
                                              ])
                                        : Container(
                                            child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 20),
                                              Text(
                                                'Your Rating:',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                              ),
                                              SizedBox(width: 10),
                                              RatingBar.builder(
                                                initialRating: _rating,
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 30,
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  setState(() {
                                                    _rating = rating;
                                                  });
                                                },
                                                ignoreGestures: true,
                                              ),
                                            ],
                                          )),
                                  )
                                ],
                              )
                            ],
                          )),
                    ],
                  ),
                );
              }
            }));
  }
}

// RatingBar.builder(
// initialRating: 5,
// itemCount: 5,
// itemBuilder: (context, index) {
// switch (index) {
// case 0:
// return Icon(
// Icons.sentiment_very_dissatisfied,
// color: Colors.red,
// );
// case 1:
// return Icon(
// Icons.sentiment_dissatisfied,
// color: Colors.redAccent,
// );
// case 2:
// return Icon(
// Icons.sentiment_neutral,
// color: Colors.amber,
// );
// case 3:
// return Icon(
// Icons.sentiment_satisfied,
// color: Colors.lightGreen,
// );
// case 4:
// return Icon(
// Icons.sentiment_very_satisfied,
// color: Colors.green,
// );
// }
//
// return Container();
// },
// onRatingUpdate: (rating) async {
// setState(() {
// _rating = rating;
// });
// await addRatingToFirestore();
// }),
