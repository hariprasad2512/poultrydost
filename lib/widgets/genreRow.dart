import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showtime/screens/browse.dart';
import 'package:showtime/widgets/trending_widget.dart';

import '../screens/home_screen.dart';
import '../services/global_methods.dart';

class GenreHeading extends StatelessWidget {
  final String genre;
  final List<String> postersList;
  final HomeScreen1 widget;
  final Map<String, int> posterToId;
  final bool isTV;
  GenreHeading(
      {super.key,
      required this.isTV,
      required this.genre,
      required this.widget,
      required this.postersList,
      required this.posterToId});
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            genre,
            style: GoogleFonts.roboto(
              fontSize: 23,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BrowseAll(
                      posterToId: posterToId,
                      heading: genre,
                      allPosters: postersList,
                      isTV: isTV,
                      watchedList: widget.watchedList,
                      watchList: widget.watchList,
                    ),
                  ));
            },
            child: Text(
              'Browse All',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class GenreRow extends StatelessWidget {
  GenreRow(
      {super.key,
      required this.size,
      required this.widget,
      required this.genreList,
      required this.startingIndex,
      required this.posterToId,
      required this.isTV});
  final Size size;
  final HomeScreen1 widget;
  final int startingIndex;
  final List<String> genreList;
  final Map<String, int> posterToId;
  final bool isTV;
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = brightness == Brightness.dark;
    return Row(
      children: [
        Flexible(
          child: SizedBox(
            height: size.height * 0.4,
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: 12,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) {
                  final int itemIndex = index + startingIndex;
                  return TrendingWidget(
                    isTV: isTV,
                    movieId: posterToId[genreList[itemIndex]],
                    posterPath: genreList[itemIndex],
                    title: 'TMDB API',
                    watchedList: widget.watchedList,
                    watchList: widget.watchList,
                  );
                }),
          ),
        ),
      ],
    );
  }
}
