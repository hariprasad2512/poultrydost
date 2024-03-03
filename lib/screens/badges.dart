import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/utils.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
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
  String badge = '';
  String tickMarkURL =
      'https://cdn.pixabay.com/photo/2016/03/31/14/37/check-mark-1292787_1280.png';
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

  void getBadge(int count) {
    if (count >= 0 && count <= 10) {
      badge = badges[0];
    } else if (count > 10 && count <= 20) {
      badge = badges[0];
    } else if (count > 20 && count <= 50) {
      badge = badges[1];
    } else if (count > 50 && count <= 100) {
      badge = badges[2];
    } else if (count > 100 && count <= 150) {
      badge = badges[3];
    } else if (count > 150 && count <= 200) {
      badge = badges[4];
    } else if (count > 200 && count <= 250) {
      badge = badges[5];
    } else if (count > 250 && count <= 300) {
      badge = badges[6];
    } else if (count > 300 && count <= 400) {
      badge = badges[8];
    } else if (count > 400 && count <= 500) {
      badge = badges[9];
    } else {
      badge = badges[9];
    }
  }

  Future<void> getWatchedMoviesCount() async {
    try {
      final _currentCount =
          await getMoviePosterURLs(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        getBadge(_currentCount);
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {
    final size = Utils(context).getScreenSize;
    bool isDark = brightness == Brightness.dark;
    setState(() {
      getWatchedMoviesCount();
    });
    return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          title: Text(
            'Earn Badges',
            style: GoogleFonts.roboto(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black),
          ),
          leading: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 15),
              child: FaIcon(
                FontAwesomeIcons.chevronLeft,
                color: isDark ? Colors.white : Colors.black,
                size: 25,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: GridView.count(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            padding: EdgeInsets.zero,
            childAspectRatio: size.width / (size.height * 1.10),
            children: List.generate(10, (index) {
              final isBadgeAchieved = index <= badges.indexOf(badge);

              return Material(
                color: isDark ? Colors.black : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    badgeDetails[badges[index]]['url'],
                                    // height: 200,
                                    // width: 130,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(height: 50),
                                Row(
                                  children: [
                                    SizedBox(
                                        width: (index < 3 ||
                                                index == 4 ||
                                                index == 7)
                                            ? 30
                                            : 20),
                                    SizedBox(
                                      child: Text(
                                        badges[index].toUpperCase(),
                                        style: GoogleFonts.playfairDisplay(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        SizedBox(
                          width: 120,
                          child: isBadgeAchieved
                              ? Image.network(tickMarkURL,
                                  height: 60, width: 60)
                              : Text(
                                  "Watch ${badgeDetails[badges[index]]['maxLength']}+ movies",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark ? Colors.white : Colors.black),
                                ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
          ),
        ));
  }
}
