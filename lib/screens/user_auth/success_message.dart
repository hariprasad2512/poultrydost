import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:showtime/screens/bottom_bar.dart';

class SuccessMessage extends StatefulWidget {
  SuccessMessage(
      {super.key,
      this.email,
      required this.watchedList,
      required this.watchList});
  final String? email;
  final List<num> watchedList;
  final List<num> watchList;
  @override
  State<SuccessMessage> createState() => _SuccessMessageState();
}

class _SuccessMessageState extends State<SuccessMessage> {
  late String name = 'Guest';
  late String emailAddress;
  late String posterURL = '';
  Future<void> getData(String? email) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.email)
        .get();

    setState(() {
      name = documentSnapshot.get('name');
      emailAddress = documentSnapshot.get('email');
      posterURL = documentSnapshot.get('profilePic');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.email != '') {
      getData(widget.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.email);
    print(name);
    return (widget.email != null)
        ? Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  foregroundImage: NetworkImage(posterURL),
                  radius: 40,
                ),
                SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      SizedBox(width: 40),
                      SizedBox(
                        width: 300,
                        child: Center(
                            child: Text(
                          "Hey there , ${name ?? ""}",
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.black,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomBarScreen(
                                  languageString: 'te',
                                  watchedList: widget.watchedList,
                                  watchList: widget.watchList)),
                          (route) => false);
                    },
                    child: Text('Go To Home Screen'))
              ],
            ),
          )
        : Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      SizedBox(width: 25),
                      Center(
                          child: Text(
                        "Welcome to ShowTime",
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomBarScreen(
                                    selectedIndex: 0,
                                    watchedList: widget.watchedList,
                                    watchList: widget.watchList,
                                    languageString: 'te',
                                  )));
                    },
                    child: Text('Go To Home Screen'))
              ],
            ),
          );
  }
}
