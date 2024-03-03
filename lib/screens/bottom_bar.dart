import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:showtime/screens/search_screen.dart';
import 'package:showtime/screens/browse.dart';
import 'package:showtime/screens/home_screen.dart';
import 'package:showtime/screens/user_auth/phone.dart';
import 'package:showtime/screens/user_screen.dart';
import 'package:showtime/screens/user_screen_notLogged.dart';
import 'package:showtime/screens/watchList.dart';

class BottomBarScreen extends StatefulWidget {
  BottomBarScreen(
      {super.key,
      this.selectedIndex,
      required this.watchedList,
      required this.watchList,
      this.languageString});
  late int? selectedIndex;
  final List<num> watchedList;
  final List<num> watchList;
  late String?  languageString;

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final List<Map<String, dynamic>> pages = [
    {'page': '', 'title': 'Home'},
    {'page': '', 'title': 'Search'},
    {'page': '', 'title': 'WatchList'},
    {'page': MyPhone(), 'title': 'Your Account'},
  ];
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  void changePage(int index) {
    setState(() {
      widget.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = brightness == Brightness.dark;
    pages[0]['page'] = HomeScreen1(
      watchedList: widget.watchedList,
      watchList: widget.watchList,
      languageString: widget.languageString ?? 'te',
    );
    pages[1]['page'] = HomeScreen(
        watchedList: widget.watchedList, watchList: widget.watchList);
    pages[2]['page'] = WatchListScreen(
        watchedList: widget.watchedList, watchList: widget.watchList);

    if (auth.currentUser != null) {
      setState(() {
        pages[3] = {
          'page': UserScreen(
            watchedList: widget.watchedList,
            watchList: widget.watchList,
          ),
          'title': 'User Preferences'
        };
      });
    } else {
      setState(() {
        pages[3] = {'page': MyPhone(), 'title': 'My Account'};
      });
    }
    int selectedIndexDef = widget.selectedIndex ?? 0;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(pages[selectedIndex]['title']),
      // ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: pages[selectedIndexDef]['page'],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        selectedItemColor: Colors.red,
        unselectedItemColor: isDarkMode ? Colors.white : Colors.black54,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndexDef,
        onTap: (currentIndex) => {changePage(currentIndex)},
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house,
                color: isDarkMode ? Colors.white : Colors.black54),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.magnifyingGlass,
                color: isDarkMode ? Colors.white : Colors.black54),
            label: "Browse",
          ),
          BottomNavigationBarItem(
            // icon: FaIcon(
            //   FontAwesomeIcons.list,
            // ),
            label: "WatchList",
            icon: FaIcon(FontAwesomeIcons.list,
                color: isDarkMode ? Colors.white : Colors.black54),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user,
                color: isDarkMode ? Colors.white : Colors.black54),
            label: "My Account",
          ),
        ],
      ),
    );
  }
}
