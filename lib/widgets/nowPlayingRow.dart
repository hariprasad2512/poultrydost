import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showtime/widgets/trending_widget.dart';

import '../screens/home_screen.dart';

class NowPlayingRow extends StatefulWidget {
  const NowPlayingRow({
    super.key,
    required this.size,
    required this.widget,
  });

  final Size size;
  final HomeScreen1 widget;

  @override
  State<NowPlayingRow> createState() => _NowPlayingRowState();
}

class _NowPlayingRowState extends State<NowPlayingRow> {
  @override
  void initState() {
    // TODO: implement initState
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10),
        RotatedBox(
          quarterTurns: -1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 60),
              Text(
                'Now Playing',
                style: GoogleFonts.montserrat(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              FaIcon(
                FontAwesomeIcons.ticketSimple,
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
        Flexible(
          child: SizedBox(
            height: widget.size.height * 0.4,
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: 10,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) {
                  return TrendingWidget(
                    movieId: widget
                        .widget.posterToId[widget.widget.postersFor1[index]],
                    posterPath: widget.widget.postersFor1[index],
                    title: 'Bhaag Saale',
                    isTV: false,
                    watchedList: widget.widget.watchedList,
                    watchList: widget.widget.watchList,
                  );
                }),
          ),
        ),
      ],
    );
  }
}
