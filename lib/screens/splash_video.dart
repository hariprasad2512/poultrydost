import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

class SplashVideo extends StatefulWidget {
  const SplashVideo({super.key});

  @override
  State<SplashVideo> createState() => _SplashVideoState();
}

class _SplashVideoState extends State<SplashVideo> {
  late VideoPlayerController _controller;
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  @override
  void initState() {
    super.initState();
    bool isDarkMode = brightness == Brightness.dark;
    print("Dark Mode is $isDarkMode");
    _controller = isDarkMode
        ? (VideoPlayerController.asset(
            'assets/logoGIF.mp4',
          )
          ..initialize().then((_) {
            setState(() {});
          })
          ..setVolume(0.0))
        : (VideoPlayerController.asset(
            'assets/logoGIF_light.mp4',
          )
          ..initialize().then((_) {
            setState(() {});
          })
          ..setVolume(0.0));

    _playVideo();
  }

  void _playVideo() async {
    // playing video
    _controller.play();

    //add delay till video is complite
    await Future.delayed(const Duration(seconds: 5));

    // navigating to home screen
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(
                  _controller,
                ),
              )
            : Container(),
      ),
    );
  }
}
