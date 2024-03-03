import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showtime/screens/person.dart';

class CastWidget extends StatefulWidget {
  const CastWidget(
      {super.key,
      required this.posterPath,
      required this.actorName,
      required this.character,
      required this.personId,
      required this.castOrNot,
      required this.watchedList,
      required this.watchList});
  final String posterPath;
  final String actorName;
  final String character;
  final num personId;
  final bool castOrNot;
  final List<num> watchedList;
  final List<num> watchList;

  @override
  State<CastWidget> createState() => _CastWidgetState();
}

class _CastWidgetState extends State<CastWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PersonPage(
                                personId: widget.personId,
                                isCastOrnot: widget.castOrNot,
                                watchedList: widget.watchedList,
                                watchList: widget.watchList,
                              )));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(widget.posterPath,
                      height: 150, width: 150, fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  child: Text(
                    widget.actorName,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  child: Text(
                    widget.character,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
