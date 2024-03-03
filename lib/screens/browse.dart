import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/utils.dart';
import '../widgets/trending_widget.dart';

class BrowseAll extends StatefulWidget {
  static const routeName = '/browseAllScreen';
  final String heading;
  final List<num> watchedList;
  final List<num> watchList;
  BrowseAll(
      {required this.heading,
      required this.allPosters,
      required this.posterToId,
      required this.isTV,
      required this.watchedList,
      required this.watchList});
  final List<String> allPosters;
  final Map<String, int> posterToId;
  final bool isTV;
  @override
  State<BrowseAll> createState() => _BrowseAllState();
}

class _BrowseAllState extends State<BrowseAll> {
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  Widget build(BuildContext context) {
    final size = Utils(context).getScreenSize;

    int normalCount = (widget.heading == 'Only on Netflix' ||
            widget.heading == 'Prime Video' ||
            widget.heading == 'Disney+ Hotstar' ||
            widget.heading == 'Zee5' ||
            widget.heading == 'Jio Cinema')
        ? 39
        : 16;

    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          title: Text(
            widget.heading,
            style: GoogleFonts.roboto(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black),
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
                color: isDarkMode ? Colors.white : Colors.black,
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
            children: List.generate(normalCount, (index) {
              int startingIndex = 0;
              return BrowseAllWidget(
                posterPath: widget.allPosters[index + startingIndex],
                movieId:
                    widget.posterToId[widget.allPosters[index + startingIndex]],
                title: 'TMDB API',
                isTV: widget.isTV,
                watchedList: widget.watchedList,
                watchList: widget.watchList,
              );
            }),
          ),
        ));
  }
}
