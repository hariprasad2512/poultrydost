import 'package:card_swiper/card_swiper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/home_screen.dart';
import '../screens/movie_screen.dart';

class Carousel extends StatefulWidget {
  Carousel({
    super.key,
    required this.size,
    required this.widget,
  });

  final Size size;
  final HomeScreen1 widget;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int activeIndex = 0;
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = brightness == Brightness.dark;
    Widget buildImage(String urlImage, int index, String title, int? movieId) =>
        Container(
            margin: EdgeInsets.symmetric(horizontal: 12),
            color: isDarkMode ? Colors.black : Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieScreen(
                        isTv: false,
                        id: movieId,
                        watchedList: widget.widget.watchedList,
                        watchList: widget.widget.watchList,
                      ),
                    ));
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey,
                  image: DecorationImage(
                    image: NetworkImage(
                      urlImage,
                    ),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    SizedBox(height: 25),
                  ],
                ),
              ),
            ));
    return SizedBox(
        height: widget.size.height * 0.4,
        child: CarouselSlider.builder(
          itemCount: 10,
          options: CarouselOptions(
            onPageChanged: (index, reason) =>
                {setState(() => activeIndex = index)},
            height: 300,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
          ),
          itemBuilder: (context, index, realIndex) {
            String title = widget.widget.titles[index];
            final urlImage = widget.widget.backdropPaths[index];
            int? movieId =
                widget.widget.posterToId[widget.widget.backdropPaths[index]];
            return buildImage(urlImage, index, title, movieId);
          },
        )

        // child: Swiper(
        //   itemBuilder: (BuildContext context, int index) {
        //     // return Image.network(
        //     //   widget.backdropPaths[index],
        //     //   fit: BoxFit.fill,
        //     // );
        //     int? movieId = widget.posterToId[widget.backdropPaths[index]];
        //     return InkWell(
        //       onTap: () {
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => MovieScreen(
        //                 isTv: false,
        //                 id: movieId,
        //               ),
        //             ));
        //       },
        //       child: Container(
        //         height: size.height * 0.4,
        //         width: MediaQuery.of(context).size.width,
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(0),
        //           color: Colors.grey,
        //           image: DecorationImage(
        //             image: NetworkImage(
        //               widget.backdropPaths[index],
        //             ),
        //             fit: BoxFit.fill,
        //           ),
        //         ),
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.end,
        //           children: [
        //             Text(
        //               widget.titles[index],
        //               style: GoogleFonts.montserrat(
        //                   fontSize: 28,
        //                   fontWeight: FontWeight.w500,
        //                   color: Colors.white),
        //             ),
        //             SizedBox(height: 25),
        //           ],
        //         ),
        //       ),
        //     );
        //   },
        //   itemCount: 10,
        //   pagination: const SwiperPagination(
        //     alignment: Alignment.bottomCenter,
        //     builder: DotSwiperPaginationBuilder(
        //         color: Colors.grey, activeColor: Colors.redAccent),
        //   ),
        //   control: SwiperControl(color: Colors.black54),
        // ),
        );
  }
}
