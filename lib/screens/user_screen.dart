import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:showtime/screens/badges.dart';
import 'package:showtime/screens/bottom_bar.dart';
import 'package:showtime/screens/edit_user.dart';
import 'package:showtime/screens/language.dart';
import 'package:showtime/screens/splashScreen.dart';
import 'package:showtime/screens/watchedList.dart';

class UserScreen extends StatefulWidget {
  UserScreen({super.key, required this.watchedList, required this.watchList});
  final List<num> watchedList;
  final List<num> watchList;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  int currentIndex = 0;
  late var accentColor = Color(0xffededed);

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

  late var currentLength = 0;
  late var maxLength = 50;
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

  late Future<List<void>> _data;
  late String nextBadge = 'silver';
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

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

  String badge = 'bronze';
  void getBadge(int count) {
    if (count >= 0 && count <= 10) {
      badge = badges[0];

      nextBadge = badges[1];
      accentColor = badgeDetails[nextBadge]['color'];
    } else if (count > 10 && count <= 20) {
      badge = badges[0];
      nextBadge = badges[1];
      accentColor = badgeDetails[nextBadge]['color'];
    } else if (count > 20 && count <= 50) {
      badge = badges[1];
      nextBadge = badges[2];
      accentColor = badgeDetails[nextBadge]['color'];
    } else if (count > 50 && count <= 100) {
      badge = badges[2];

      nextBadge = badges[3];
      accentColor = badgeDetails[nextBadge]['color'];
    } else if (count > 100 && count <= 150) {
      badge = badges[3];

      nextBadge = badges[4];
      accentColor = badgeDetails[nextBadge]['color'];
    } else if (count > 150 && count <= 200) {
      badge = badges[4];
      nextBadge = badges[5];
      accentColor = badgeDetails[nextBadge]['color'];
    } else if (count > 200 && count <= 250) {
      badge = badges[5];

      nextBadge = badges[6];
      accentColor = badgeDetails[nextBadge]['color'];
    } else if (count > 250 && count <= 300) {
      badge = badges[6];
      nextBadge = badges[7];
      accentColor = badgeDetails[nextBadge]['color'];
    } else if (count > 300 && count <= 400) {
      badge = badges[8];

      nextBadge = badges[9];
      accentColor = badgeDetails[nextBadge]['color'];
    } else if (count > 400 && count <= 500) {
      badge = badges[9];

      nextBadge = badges[9];
      accentColor = badgeDetails[nextBadge]['color'];
    } else {
      badge = badges[9];
    }
  }

  Future<void> getWatchedMoviesCount() async {
    try {
      final _currentCount =
          await getMoviePosterURLs(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        currentLength = _currentCount;
        getBadge(currentLength);
        maxLength = badgeDetails[nextBadge]['maxLength'];
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    _data = Future.wait([
      getWatchedMoviesCount(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = auth.currentUser;
    final fullName = currentUser?.displayName;
    var nameList = fullName?.split(' ');
    var firstName = nameList?[0];
    bool isDark = brightness == Brightness.dark;
    Future<void> showLogOutDialog() async {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.black : Colors.white,
              title: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.arrowRightFromBracket,
                    size: 20,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Sign Out',
                    style:
                        TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
              content: Text(
                'Are you sure you want to sign out?',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 15,
                      ),
                    )),
                TextButton(
                    onPressed: () async {
                      try {
                        await auth.signOut();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomBarScreen(
                                      selectedIndex: 3,
                                      watchedList: widget.watchedList,
                                      watchList: widget.watchList,
                                    )));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Signed Out Successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.redAccent, fontSize: 15),
                    ))
              ],
            );
          });
    }

    return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: FutureBuilder(
            future: _data,
            builder:
                (BuildContext context, AsyncSnapshot<List<void>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Splash();
              } else {
                return SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10),
                              SizedBox(
                                child: RichText(
                                    text: TextSpan(
                                        children: [
                                      TextSpan(
                                          text: '${firstName ?? "Guest"}!',
                                          style: GoogleFonts.playfairDisplay(
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 35)),
                                    ],
                                        text: ' Hey there ',
                                        style: GoogleFonts.playfairDisplay(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 35))),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Divider(
                            thickness: 2,
                            color: isDark ? Colors.white : Colors.black54,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                child: Column(
                                  children: [
                                    Text(
                                      "Get the ${nextBadge[0].toUpperCase()}${nextBadge.substring(1)} badge",
                                      style: GoogleFonts.robotoCondensed(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    SizedBox(height: 10),
                                    Image.network(
                                        badgeDetails[nextBadge]['url'],
                                        width: 90,
                                        height: 90),
                                    SizedBox(height: 0),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BadgesScreen()));
                                        },
                                        child: Text("Learn more about badges"))
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  WatchedListScreen(
                                                      watchedList:
                                                          widget.watchedList,
                                                      watchList:
                                                          widget.watchList)));
                                    },
                                    child: CircularPercentIndicator(
                                      radius: 45.0,
                                      lineWidth: 12.0,
                                      animation: true,
                                      animationDuration: 1200,
                                      circularStrokeCap:
                                          CircularStrokeCap.round,
                                      percent: ((currentLength) / (maxLength))
                                          .toDouble(),
                                      center: Text("$currentLength/$maxLength",
                                          style: GoogleFonts.roboto(
                                            fontSize: 20,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      progressColor: accentColor,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Your Watched Movies",
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          listItem(
                            title: 'Already Watched',
                            myicon: FaIcon(
                              FontAwesomeIcons.film,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WatchedListScreen(
                                          watchedList: widget.watchedList,
                                          watchList: widget.watchList)));
                            },
                          ),
                          listItem(
                            title: 'Change Language of Content',
                            myicon: FaIcon(
                              FontAwesomeIcons.language,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LanguageScreen(
                                            watchedList: widget.watchedList,
                                            watchList: widget.watchList,
                                          )));
                            },
                          ),
                          listItem(
                            title: 'Sign Out',
                            myicon: FaIcon(
                              FontAwesomeIcons.arrowRightFromBracket,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onPressed: () async {
                              await showLogOutDialog();
                            },
                          ),
                          SizedBox(
                            height: 100,
                          ),
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Powered By ',
                                  style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black),
                                ),
                                SizedBox(width: 10),
                                Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tmdb.new.logo.svg/1280px-Tmdb.new.logo.svg.png',
                                height: 50,width: 50,),
                              ],
                            ),
                            onTap: () {
                              print("TMDB API");
                            },
                          ),
                          SizedBox(height: 10),
                          Center(child: Text('© ShowTime 2023' , style: TextStyle(color: isDark ? Colors.white : Colors.black),)),
                        ],
                      ),
                    ],
                  ),
                );
              }
            }));
  }
}

class listItem extends StatelessWidget {
  String title;
  FaIcon myicon;
  Function onPressed;
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  listItem(
      {required this.title, required this.myicon, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    bool isDark = brightness == Brightness.dark;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      leading: myicon,
      trailing: FaIcon(
        FontAwesomeIcons.chevronRight,
        color: isDark ? Colors.white : Colors.black,
      ),
      onTap: () {
        onPressed();
      },
    );
  }
}
