import 'dart:core';

import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/badge/gf_badge.dart';
import 'package:getwidget/components/badge/gf_button_badge.dart';
import 'package:getwidget/components/badge/gf_icon_badge.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';
import 'package:getwidget/components/carousel/gf_items_carousel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:showtime/common/api_constants.dart';
import 'package:showtime/screens/bottom_bar.dart';
import 'package:showtime/screens/splashScreen.dart';
import 'package:showtime/services/global_methods.dart';
import 'package:showtime/services/utils.dart';
import 'package:showtime/widgets/trending_widget.dart';
import '../common/api_client.dart';
import '../data/movie_remote_data_source.dart';
import '../widgets/carousel.dart';
import '../widgets/genreRow.dart';
import '../widgets/nowPlayingRow.dart';
import 'browse.dart';

class HomeScreen1 extends StatefulWidget {
  HomeScreen1(
      {super.key,
      this.languageString,
      required this.watchedList,
      required this.watchList});
  List<String> backdropPaths = [];
  final List<num> watchedList;
  final List<num> watchList;
  String? languageString = 'en';
  List<String> titles = [];
  List<String> postersFor1 = [];
  List<String> actionPosters = [];
  List<String> adventurePosters = [];
  List<String> animationPosters = [];
  List<String> comedyPosters = [];
  List<String> romancePosters = [];
  List<String> crimePosters = [];
  List<String> dramaPosters = [];
  List<String> horrorMovies = [];
  List<String> thrillerMovies = [];
  List<String> trendingTVSeries = [];
  List<String> madeInIndia = [];
  List<String> netflixSeries = [];
  List<String> primeSeries = [];
  Map<String, int> posterToId = {};
  Map<String, List<String>> ottPosters = {
    'netflix': [],
    'prime': [],
    'hotstar': [],
    'zee5': [],
    'jiocinema': []
  };
  final List<String> imageList = [
    "https://media.istockphoto.com/id/480600067/photo/secret-agent-armed-with-handgun.jpg?s=612x612&w=0&k=20&c=yY4FbjExkYDoIiO5ZPrD2unWQwWrZRzJeK3HXLnK1_o=",
    "https://m.economictimes.com/thumb/msid-101705697,width-1920,height-1280,resizemode-4,imgsize-153966/mission-impossible-7-tom-cruise-performs-deadly-motorbike-stunt-heres-how.jpg",
    "https://www.lcca.org.uk/media/671026/justin-lim-500765-unsplash.jpg?mode=crop&quality=75&width=860&height=485",
    "https://resize.indiatvnews.com/en/resize/newbucket/1200_-/2018/04/chaplinbig-1523841093.jpg",
    "https://www.deccanherald.com/sites/dh/files/styles/article_detail/public/articleimages/2022/05/05/crime-scene-istock-1106155-1651587536-1106569-1651717390.jpg?itok=kohx4bKR",
    "https://media-cldnry.s-nbcnews.com/image/upload/t_social_share_1200x630_center,f_auto,q_auto:best/rockcms/2022-07/family-quotes-2x1-bn-220712-8a4afd.jpg",
    "https://www.fortressofsolitude.co.za/wp-content/uploads/2017/09/Pennywise-ITs-Evil-Creepy-Clown-Has-An-Incredible-Backstory-scaled.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyoIRrpibxZklldaIHuO5ZsR7OwzFoLwaXkw&usqp=CAU",
    "https://s26162.pcdn.co/wp-content/uploads/sites/3/2022/09/spiral-staircase-feat.jpg"
  ];

  final List<String> ottList = [
    "assets/ott/netflix.png",
    "assets/ott/prime.jpg",
    "assets/ott/hotstar.jpg",
    "assets/ott/zee5.jpg",
    "assets/ott/jiocinema.jpg"
  ];

  final List<String> ottUrls = [
    "https://www.edigitalagency.com.au/wp-content/uploads/Netflix-logo-red-black-png.png",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRU-kjovMpgPJIGxkiiSgr2NeY0uHDOpfzPvd7UEZ4x&s",
    "https://i.gadgets360cdn.com/large/disney_plus_hotstar_logo_1583901149861.jpg",
    "https://www.exchange4media.com/news-photo/100664-Zee5logo.jpg"
  ];

  @override
  State<HomeScreen1> createState() => _HomeScreen1State();
}

class _HomeScreen1State extends State<HomeScreen1> {
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  List<String> badges = [
    'bronze',
    'silver',
    'gold',
    'sapphire',
    'ruby',
    'emerald',
    'amethyst',
    'pearl',
    'obsidian',
    'diamond'
  ];

  Map<String, dynamic> badgeDetails = {
    'bronze': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/c/c4/Badge_Bronze_Blank.png/revision/latest?cb=20190918142913',
      'color': Color(0xffd6aa82),
      'maxLength': 10
    },
    'silver': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/2/24/Badge_Silver_Blank.png/revision/latest?cb=20190918145651',
      'color': Color(0xffededed),
      'maxLength': 20
    },
    'gold': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/d/d8/Badge_Gold_Blank.png/revision/latest?cb=20190918150250',
      'color': Color(0xffFED540),
      'maxLength': 50
    },
    'sapphire': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/c/cd/Badge_Sapphire_Blank.png/revision/latest?cb=20190918150223',
      'color': Color(0xff37B9F7),
      'maxLength': 100
    },
    'ruby': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/0/00/Badge_Ruby_Blank.png/revision/latest?cb=20190918150636',
      'color': Color(0xffFF6060),
      'maxLength': 150
    },
    'emerald': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/5/59/Badge_Emerald_Blank.png/revision/latest?cb=20190918150150',
      'color': Color(0xff88CF1F),
      'maxLength': 200
    },
    'amethyst': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/b/bf/Badge_Amethyst_Blank.png/revision/latest?cb=20190918150114',
      'color': Color(0xffD28DFF),
      'maxLength': 250
    },
    'pearl': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/5/5c/Badge_Pearl_Blank.png/revision/latest?cb=20190918145950',
      'color': Color(0xffFFB6E2),
      'maxLength': 300
    },
    'obsidian': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/b/b2/Badge_Obsidian_Blank.png/revision/latest?cb=20190918145821',
      'color': Color(0xff515059),
      'maxLength': 400
    },
    'diamond': {
      'url':
          'https://static.wikia.nocookie.net/duolingo/images/c/c7/Badge_Diamond_Blank.png/revision/latest?cb=20190918145738',
      'color': Color(0xff94EFEF),
      'maxLength': 500
    },
  };

  Future<int> getMoviePosterURLs(String uid) async {
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
      return movieIds.length;
    } catch (error) {
      print('Error retrieving movie poster URLs: $error');
      rethrow;
    }
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

  String badge = '';
  String badgeURL = '';
  void getBadge(int count) {
    if (count >= 0 && count <= 10) {
      badge = badges[0];
      //accentColor = badgeDetails[badge]['color'];
      //nextBadge = badge[1]
    } else if (count > 10 && count <= 20) {
      badge = badges[0];
      //nextBadge = badge[2];
      //accentColor = badgeDetails[badge]['color'];
    } else if (count > 20 && count <= 50) {
      badge = badges[1];
      //accentColor = badgeDetails[badge]['color'];
      //nextBadge = badge[3];
    } else if (count > 50 && count <= 100) {
      badge = badges[2];
      //accentColor = badgeDetails[badge]['color'];
      //nextBadge = badge[4];
    } else if (count > 100 && count <= 150) {
      badge = badges[3];
      //accentColor = badgeDetails[badge]['color'];
      //nextBadge = badge[5];
    } else if (count > 150 && count <= 200) {
      badge = badges[4];
      //accentColor = badgeDetails[badge]['color'];
      //nextBadge = badge[6];
    } else if (count > 200 && count <= 250) {
      badge = badges[5];
      //accentColor = badgeDetails[badge]['color'];
      //nextBadge = badge[7];
    } else if (count > 250 && count <= 300) {
      badge = badges[6];
      //accentColor = badgeDetails[badge]['color'];
      //nextBadge = badge[8];
    } else if (count > 300 && count <= 400) {
      badge = badges[7];
      //accentColor = badgeDetails[badge]['color'];
      //nextBadge = badge[9];
    } else if (count > 400 && count <= 500) {
      badge = badges[8];
      //accentColor = badgeDetails[badge]['color'];
      //nextBadge = badge[9];
    } else {
      badge = badges[9];
    }
  }

  String url = '';
  int currentLength = 0;
  Future<void> getWatchedMoviesCount() async {
    try {
      final _currentCount =
          await getMoviePosterURLs(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        currentLength = _currentCount;
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getMovieDetails() async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);

    final movies = await dataSource.getPopular(widget.languageString);

    movies?.forEach((movie) {
      final posterPath = movie.backdropPath;
      if (posterPath != null) {
        final posterURL = '${APIConstants.baseImageURL}$posterPath';
        final title = movie.title;
        widget.backdropPaths.add(posterURL);
        widget.titles.add(title);
        final movieId = movie.id;
        widget.posterToId[posterURL] = movieId;
      }
    });
  }

  Future<void> getUSTVShows() async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);

    final movies = await dataSource.getTrending(widget.languageString);

    movies?.forEach((movie) {
      final posterPath = movie.posterPath;
      if (posterPath != null) {
        final posterURL = '${APIConstants.baseImageURL}$posterPath';
        widget.trendingTVSeries.add(posterURL);
        final movieId = movie.id;
        widget.posterToId[posterURL] = movieId;
      }
    });
  }

  Future<void> getPosters() async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);

    final movies = await dataSource.getNowPlaying(widget.languageString);

    movies?.forEach((movie) {
      final posterPath = movie.posterPath;
      if (posterPath != null) {
        final posterURL = 'https://image.tmdb.org/t/p/w500$posterPath';
        // final title = movie.title;
        // widget.backdropPaths.add(posterURL);
        // widget.titles.add(title);
        widget.postersFor1.add(posterURL);
        final movieId = movie.id;
        widget.posterToId[posterURL] = movieId;
      }
    });
  }

  Future<void> getOTTMovies(String ott, int ottId, int page_no) async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);

    final movies =
        await dataSource.getMoviesByOTT(ottId, page_no, widget.languageString);

    int len = 0;
    movies?.forEach((movie) {
      final posterPath = movie.posterPath;
      if (posterPath != null) {
        final posterURL = 'https://image.tmdb.org/t/p/w500$posterPath';
        // final title = movie.title;
        // widget.backdropPaths.add(posterURL);
        // widget.titles.add(title);
        widget.ottPosters[ott]?.add(posterURL);
        final movieId = movie.id;
        widget.posterToId[posterURL] = movieId;
      }
    });
  }

  Future<void> getGenreMovies(String genre, int genreId) async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);

    final movies =
        await dataSource.getMoviesByGenre(genreId, widget.languageString);

    int len = 0;
    movies?.forEach((movie) {
      final posterPath = movie.posterPath;
      if (posterPath != null) {
        final posterURL = 'https://image.tmdb.org/t/p/w500$posterPath';
        // final title = movie.title;
        // widget.backdropPaths.add(posterURL);
        // widget.titles.add(title);
        if (genreId == 28) {
          widget.actionPosters.add(posterURL);
          final movieId = movie.id;
          widget.posterToId[posterURL] = movieId;
        } else if (genreId == 12) {
          widget.adventurePosters.add(posterURL);
          final movieId = movie.id;
          widget.posterToId[posterURL] = movieId;
        } else if (genreId == 16) {
          widget.animationPosters.add(posterURL);
          final movieId = movie.id;
          widget.posterToId[posterURL] = movieId;
        } else if (genreId == 35) {
          widget.comedyPosters.add(posterURL);
          final movieId = movie.id;
          widget.posterToId[posterURL] = movieId;
        } else if (genreId == 18) {
          widget.dramaPosters.add(posterURL);
          final movieId = movie.id;
          widget.posterToId[posterURL] = movieId;
        } else if (genreId == 80) {
          widget.crimePosters.add(posterURL);
          final movieId = movie.id;
          widget.posterToId[posterURL] = movieId;
        } else if (genreId == 27) {
          widget.horrorMovies.add(posterURL);
          final movieId = movie.id;
          widget.posterToId[posterURL] = movieId;
        } else if (genreId == 10749) {
          widget.romancePosters.add(posterURL);
          final movieId = movie.id;
          widget.posterToId[posterURL] = movieId;
        } else if (genreId == 53) {
          widget.thrillerMovies.add(posterURL);
          final movieId = movie.id;
          widget.posterToId[posterURL] = movieId;
        }
      }
    });
  }

  Future<void> getIndianMovies() async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);

    final movies = await dataSource.getMoviesByPath(
        'discover/movie?language=en-US&with_original_language=${widget.languageString}');

    movies?.forEach((movie) {
      final posterPath = movie.posterPath;
      if (posterPath != null) {
        final posterURL = '${APIConstants.baseImageURL}$posterPath';
        widget.madeInIndia.add(posterURL);
        final movieId = movie.id;
        widget.posterToId[posterURL] = movieId;
      }
    });
  }

  Future<void> getNetflixSeries() async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);

    final movies = await dataSource.getMoviesByNetwork(
        'discover/tv?with_original_language=${widget.languageString}', 213);

    movies?.forEach((movie) {
      final posterPath = movie.posterPath;
      if (posterPath != null) {
        final posterURL = '${APIConstants.baseImageURL}$posterPath';
        widget.netflixSeries.add(posterURL);
        final movieId = movie.id;
        widget.posterToId[posterURL] = movieId;
      }
    });
  }

  Future<void> getPrimeSeries() async {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);

    final movies = await dataSource.getMoviesByNetwork(
        'discover/tv?with_original_language=${widget.languageString}', 1024);

    movies?.forEach((movie) {
      final posterPath = movie.posterPath;
      if (posterPath != null) {
        final posterURL = '${APIConstants.baseImageURL}$posterPath';
        widget.primeSeries.add(posterURL);
        final movieId = movie.id;
        widget.posterToId[posterURL] = movieId;
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print(widget.languageString);
    setState(() {
      getWatchedMoviesCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = Utils(context).getScreenSize;
    String currentBadge = '';
    setState(() {
      getBadge(currentLength);
    });
    bool isDarkMode = brightness == Brightness.dark;
    connectFirebase();
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool isScrollable) {
          return [
            SliverAppBar(
              backgroundColor: isDarkMode ? Colors.black : Colors.transparent,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomBarScreen(
                                  watchedList: widget.watchedList,
                                  watchList: widget.watchList,
                                  selectedIndex: 3,
                                )),
                        (route) => false);
                  },
                  child: FirebaseAuth.instance.currentUser == null
                      ? Text(
                          'Sign In',
                          style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.blueAccent),
                        )
                      : Image.network(badgeDetails[badge]['url'],
                          width: 35, height: 35),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.black),
                  ),
                )
              ],
              floating: true,
              leading: Row(
                children: [
                  SizedBox(width: 15),
                  Image.asset('assets/logo.png', width: 40, height: 40),
                ],
              ),
              title: Text(
                'ShowTime',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black),
              ),
            )
          ];
        },
        body: FutureBuilder<List<void>>(
          future: Future.wait([
            getMovieDetails(),
            getPosters(),
            getOTTMovies('netflix', 8, 1),
            getOTTMovies('netflix', 8, 2),
            getOTTMovies('netflix', 8, 3),
            getUSTVShows(),
            getIndianMovies(),
            getNetflixSeries(),
            getPrimeSeries(),
            getGenreMovies('Action', 28),
            getGenreMovies('Adventure', 12),
            getGenreMovies('Animation', 16),
            getGenreMovies('Comedy', 35),
            getGenreMovies('Drama', 18),
            getGenreMovies('Crime', 80),
            getGenreMovies('Horror', 27),
            getGenreMovies('Romance', 10749),
            getGenreMovies('Thriller', 53),
            getOTTMovies('prime', 119, 1),
            getOTTMovies('prime', 119, 2),
            getOTTMovies('prime', 119, 3),
            getOTTMovies('hotstar', 122, 1),
            getOTTMovies('hotstar', 122, 2),
            getOTTMovies('hotstar', 122, 3),
            getOTTMovies('zee5', 232, 1),
            getOTTMovies('zee5', 232, 2),
            getOTTMovies('zee5', 232, 3),
            getOTTMovies('jiocinema', 220, 1),
            getOTTMovies('jiocinema', 220, 2),
            getOTTMovies('jiocinema', 220, 3),
          ]),
          builder: (BuildContext context, AsyncSnapshot<List<void>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Splash();
            } else {
              return SafeArea(
                child: ListView(physics: BouncingScrollPhysics(), children: [
                  Carousel(size: size, widget: widget),
                  Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Watch by Platform',
                            style: GoogleFonts.roboto(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: SizedBox(
                              height: 120,
                              child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: 4,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (ctx, idx) {
                                    String headingText = '';
                                    List<String> genrePosterList = [];
                                    bool isTv = false;
                                    if (idx == 0) {
                                      headingText = 'Only on Netflix';
                                      genrePosterList =
                                          widget.ottPosters['netflix']!;
                                    } else if (idx == 1) {
                                      headingText = 'Prime Video';
                                      genrePosterList =
                                          widget.ottPosters['prime']!;
                                    } else if (idx == 2) {
                                      headingText = 'Disney+ Hotstar';
                                      genrePosterList =
                                          widget.ottPosters['hotstar']!;
                                    } else if (idx == 3) {
                                      headingText = 'Zee5';
                                      genrePosterList =
                                          widget.ottPosters['zee5']!;
                                    } else if (idx == 4) {
                                      headingText = 'Jio Cinema';
                                      genrePosterList =
                                          widget.ottPosters['jiocinema']!;
                                    }

                                    return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BrowseAll(
                                                  posterToId: widget.posterToId,
                                                  heading: headingText,
                                                  allPosters: genrePosterList,
                                                  isTV: isTv,
                                                  watchedList:
                                                      widget.watchedList,
                                                  watchList: widget.watchList,
                                                ),
                                              ));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(7.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            BrowseAll(
                                                          posterToId:
                                                              widget.posterToId,
                                                          heading: headingText,
                                                          allPosters:
                                                              genrePosterList,
                                                          isTV: isTv,
                                                          watchedList: widget
                                                              .watchedList,
                                                          watchList:
                                                              widget.watchList,
                                                        ),
                                                      ));
                                                },
                                                child: Image.network(
                                                  widget.ottUrls[idx],
                                                  width: 160,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                        ));
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  NowPlayingRow(size: size, widget: widget),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Categories',
                            style: GoogleFonts.roboto(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: SizedBox(
                              height: 120,
                              child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: 9,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (ctx, idx) {
                                    String headingText = '';
                                    List<String> genrePosterList = [];
                                    bool isTv = false;
                                    if (idx == 0) {
                                      headingText = 'Action';
                                      genrePosterList = widget.actionPosters;
                                    } else if (idx == 1) {
                                      headingText = 'Adventure';
                                      genrePosterList = widget.adventurePosters;
                                    } else if (idx == 2) {
                                      headingText = 'Animation';
                                      genrePosterList = widget.animationPosters;
                                    } else if (idx == 3) {
                                      headingText = 'Comedy';
                                      genrePosterList = widget.comedyPosters;
                                    } else if (idx == 4) {
                                      headingText = 'Crime';
                                      genrePosterList = widget.crimePosters;
                                    } else if (idx == 5) {
                                      headingText = 'Drama';
                                      genrePosterList = widget.dramaPosters;
                                    } else if (idx == 6) {
                                      headingText = 'Horror';
                                      genrePosterList = widget.horrorMovies;
                                    } else if (idx == 7) {
                                      headingText = 'Romance';
                                      genrePosterList = widget.romancePosters;
                                    } else if (idx == 8) {
                                      headingText = 'Thriller';
                                      genrePosterList = widget.thrillerMovies;
                                    }

                                    return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BrowseAll(
                                                  posterToId: widget.posterToId,
                                                  heading: headingText,
                                                  allPosters: genrePosterList,
                                                  isTV: isTv,
                                                  watchedList:
                                                      widget.watchedList,
                                                  watchList: widget.watchList,
                                                ),
                                              ));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(7.0),
                                          child: Stack(children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              BrowseAll(
                                                            posterToId: widget
                                                                .posterToId,
                                                            heading:
                                                                headingText,
                                                            allPosters:
                                                                genrePosterList,
                                                            isTV: isTv,
                                                            watchedList: widget
                                                                .watchedList,
                                                            watchList: widget
                                                                .watchList,
                                                          ),
                                                        ));
                                                  },
                                                  child: Image.network(
                                                    widget.imageList[idx],
                                                    width: 200,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  )),
                                            ),
                                            Column(children: [
                                              SizedBox(
                                                height: 70,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(width: 10),
                                                  Text(
                                                    headingText,
                                                    style: GoogleFonts.raleway(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      backgroundColor: Colors
                                                          .transparent
                                                          .withOpacity(0.2),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ])
                                          ]),
                                        ));
                                  }),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      GenreHeading(
                        isTV: false,
                        genre: 'Action Movies',
                        postersList: widget.actionPosters,
                        posterToId: widget.posterToId,
                        widget: widget,
                      ),
                      GenreRow(
                        isTV: false,
                        size: size,
                        widget: widget,
                        genreList: widget.actionPosters,
                        startingIndex: 3,
                        posterToId: widget.posterToId,
                      ),
                      GenreHeading(
                        isTV: false,
                        genre: 'Thriller',
                        postersList: widget.thrillerMovies,
                        posterToId: widget.posterToId,
                        widget: widget,
                      ),
                      GenreRow(
                        isTV: false,
                        size: size,
                        widget: widget,
                        genreList: widget.thrillerMovies,
                        startingIndex: 3,
                        posterToId: widget.posterToId,
                      ),
                      Column(
                        children: widget.languageString != 'kn'
                            ? [
                                GenreHeading(
                                  widget: widget,
                                  isTV: false,
                                  genre: 'Dramas',
                                  postersList: widget.dramaPosters,
                                  posterToId: widget.posterToId,
                                ),
                                GenreRow(
                                  size: size,
                                  isTV: false,
                                  widget: widget,
                                  genreList: widget.dramaPosters,
                                  startingIndex: 2,
                                  posterToId: widget.posterToId,
                                ),
                                GenreHeading(
                                  widget: widget,
                                  isTV: false,
                                  genre: 'Romantic Stories',
                                  postersList: widget.romancePosters,
                                  posterToId: widget.posterToId,
                                ),
                                GenreRow(
                                  isTV: false,
                                  size: size,
                                  widget: widget,
                                  genreList: widget.romancePosters,
                                  startingIndex: 3,
                                  posterToId: widget.posterToId,
                                ),
                                GenreHeading(
                                  widget: widget,
                                  isTV: false,
                                  genre: 'Comedies',
                                  postersList: widget.comedyPosters,
                                  posterToId: widget.posterToId,
                                ),
                                GenreRow(
                                  size: size,
                                  isTV: false,
                                  widget: widget,
                                  genreList: widget.comedyPosters,
                                  startingIndex: 3,
                                  posterToId: widget.posterToId,
                                ),
                              ]
                            : [Container()],
                      ),
                      Column(
                        children: widget.languageString == 'en'
                            ? [
                                GenreHeading(
                                  widget: widget,
                                  isTV: true,
                                  genre: 'Top US TV Shows',
                                  postersList: widget.trendingTVSeries,
                                  posterToId: widget.posterToId,
                                ),
                                GenreRow(
                                  isTV: true,
                                  size: size,
                                  widget: widget,
                                  genreList: widget.trendingTVSeries,
                                  startingIndex: 0,
                                  posterToId: widget.posterToId,
                                ),
                                GenreHeading(
                                  widget: widget,
                                  isTV: true,
                                  genre: 'Netflix Originals',
                                  postersList: widget.netflixSeries,
                                  posterToId: widget.posterToId,
                                ),
                                GenreRow(
                                  isTV: true,
                                  size: size,
                                  widget: widget,
                                  genreList: widget.netflixSeries,
                                  startingIndex: 0,
                                  posterToId: widget.posterToId,
                                ),
                                GenreHeading(
                                  widget: widget,
                                  isTV: true,
                                  genre: 'Only on Prime Video',
                                  postersList: widget.primeSeries,
                                  posterToId: widget.posterToId,
                                ),
                                GenreRow(
                                  isTV: true,
                                  size: size,
                                  widget: widget,
                                  genreList: widget.primeSeries,
                                  startingIndex: 0,
                                  posterToId: widget.posterToId,
                                ),
                              ]
                            : [Container()],
                      ),
                    ],
                  ),
                ]),
              );
            }
          },
        ),
      ),
    );
  }
}
