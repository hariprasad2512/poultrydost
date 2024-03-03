import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:showtime/screens/movie_screen.dart';

import 'package:showtime/screens/splashScreen.dart';
import '../common/api_client.dart';
import '../common/api_constants.dart';
import '../data/movie_remote_data_source.dart';
import '../services/utils.dart';
import '../widgets/genreRow.dart';

class PersonPage extends StatefulWidget {
  PersonPage(
      {super.key,
      required this.personId,
      required this.isCastOrnot,
      required this.watchedList,
      required this.watchList});
  final num personId;
  late Map personDetails = {};
  final bool isCastOrnot;
  late List<String> moviePosters = [];
  late var postersToId = {};
  final List<num> watchedList;
  final List<num> watchList;
  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  late bool isTV = false;
  late Future<List<void>> _data;
  Future<void> getPersonInfo(num personId) async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);
    widget.personDetails = await dataSource.getPersonDetails(personId);
  }

  Future<void> getMoviePosterURLs(num personId) async {
    // Get movie IDs array from user document
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/person/$personId/movie_credits?api_key=${APIConstants.API_KEY}',
      ),
    );

    if (response.statusCode == 200) {
      var castOrCrew = widget.isCastOrnot ? 'cast' : 'crew';
      final movies = jsonDecode(response.body)[castOrCrew];
      for (var movie in movies) {
        if (movie['poster_path'] != null) {
          var posterURL =
              'https://image.tmdb.org/t/p/w500/${movie['poster_path']}';
          widget.moviePosters.add(posterURL);
          widget.postersToId[posterURL] = movie['id'];
        }
      }
    } else {
      throw Exception('Failed to fetch movie details');
    }
  }

  Future<void> determineMediaType(num mediaId) async {
    final movieUrl =
        'https://api.themoviedb.org/3/movie/$mediaId?api_key=${APIConstants.API_KEY}';
    final tvUrl =
        'https://api.themoviedb.org/3/tv/$mediaId?api_key=${APIConstants.API_KEY}';

    try {
      final movieResponse = await http.get(Uri.parse(movieUrl));
      final tvResponse = await http.get(Uri.parse(tvUrl));

      final movieData = json.decode(movieResponse.body);
      final tvData = json.decode(tvResponse.body);

      if (movieData.containsKey('id')) {
        isTV = false;
      } else if (tvData.containsKey('id')) {
        isTV = true;
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _data = Future.wait<void>([
      getPersonInfo(widget.personId),
      getMoviePosterURLs(widget.personId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    getPersonInfo(widget.personId);
    final size = Utils(context).getScreenSize;

    return Scaffold(
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
        ),
        body: FutureBuilder<List<void>>(
            future: _data,
            builder:
                (BuildContext context, AsyncSnapshot<List<void>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Splash();
              } else {
                print(widget.personDetails);
                var personName = widget.personDetails['name'];
                var posterURL =
                    'https://image.tmdb.org/t/p/w500${widget.personDetails['profile_path']}';
                var biography = widget.personDetails['biography'];
                var department = widget.personDetails['known_for_department'];
                return Container(
                    child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              posterURL,
                              width: 130,
                              height: 200,
                            )),
                      ),
                      Text(
                        personName,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        department,
                        style: GoogleFonts.roboto(
                            fontSize: 24, color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(width: 10),
                          SizedBox(
                            width: 370,
                            child: Text(
                              biography,
                              style: GoogleFonts.montserrat(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        child: Text(
                          'Worked In',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 24, color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.35,
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: 13,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (ctx, index) {
                              int startingIndex = 3 + index;
                              var movieId = widget.postersToId[
                                  widget.moviePosters[startingIndex]];
                              determineMediaType(movieId);
                              bool isTVOrNot = isTV;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MovieScreen(
                                                isTv: isTVOrNot,
                                                id: movieId,
                                                watchedList: widget.watchedList,
                                                watchList: widget.watchList)));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      widget.moviePosters[startingIndex],
                                      height: 200,
                                      width: 130,
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ));
              }
            }));
  }
}
