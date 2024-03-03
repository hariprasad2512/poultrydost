import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:showtime/common/api_constants.dart';
import 'package:showtime/data/movie_model.dart';
import '../common/api_client.dart';
import '../data/movie_remote_data_source.dart';
import '../services/movieDetails.dart';
import 'package:http/http.dart' as http;

import '../services/utils.dart';
import 'movie_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key, required this.watchedList, required this.watchList});
  final List<num> watchedList;
  final List<num> watchList;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // late String imgURL =
  //     'https://seeklogo.com/images/M/movie-time-cinema-logo-8B5BE91828-seeklogo.com.png';
  //
  bool isAddedToWatchList = false;
  bool alreadyWatched = false;
  late SearchBar searchBar;
  String searchText = '';
  List<Movie> searchResults = [];
  bool showSearchResults = false;
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        showSearchResults = false;
      });
      return;
    }

    final apiKey = APIConstants.API_KEY;
    final url = Uri.parse(
        'https://api.themoviedb.org/3/search/multi?api_key=$apiKey&query=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final results = jsonData['results'] as List<dynamic>;

      setState(() {
        showSearchResults = true;
        searchResults =
            results.map((movieData) => Movie.fromJson(movieData)).toList();
      });
    } else {
      showSnackBar('Failed to fetch search results');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');
  FirebaseAuth auth = FirebaseAuth.instance;
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);
    late String searchQuery = 'I am empty';
    bool isDark = brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.blueGrey,
        actions: [
          Padding(
              padding: EdgeInsets.all(15),
              child: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                color: Colors.white,
              ))
        ],
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: TextField(
            cursorColor: Colors.white,
            style: GoogleFonts.roboto(fontSize: 20, color: Colors.white),
            controller: _searchController,
            decoration: InputDecoration(
                hintText: 'Search movies',
                hintStyle:
                    TextStyle(color: isDark ? Colors.white60 : Colors.grey)),
            onChanged: searchMovies,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://assets.nflxext.com/ffe/siteui/vlv3/bff5732c-7d13-45d1-9fab-476db25a1827/46bc87cd-4c4c-4485-8b93-d5f21c581d56/IN-en-20230710-popsignuptwoweeks-perspective_alpha_website_small.jpg',
            fit: BoxFit.cover,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: searchResults.length == 1 ? 0.5 : 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Visibility(
                visible: showSearchResults,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final movie = searchResults[index];

                      isAddedToWatchList = widget.watchList.contains(movie.id);
                      alreadyWatched = widget.watchedList.contains(movie.id);

                      return Material(
                        color: isDark ? Colors.black : Colors.white,
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieScreen(
                                      isTv: (movie.name != null) ? true : false,
                                      id: movie.id,
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
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: movie.posterPath != null
                                              ? Image.network(
                                                  'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                                                  height: 200,
                                                  width: 130,
                                                )
                                              : Container(),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(width: 10),
                                          SizedBox(
                                              width: 220,
                                              child: movie.posterPath != null
                                                  ? Text(
                                                      movie.title ??
                                                          movie.name ??
                                                          "Unknown",
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              color: isDark
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))
                                                  : Text('')),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            )),
                      );
                    },
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
