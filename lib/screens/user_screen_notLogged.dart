import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserScreenNotLogged extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Let's Get Started",
              style: GoogleFonts.anton(
                fontSize: 50,
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'LOGIN / SIGN IN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(15),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          )
        ],
      ),
    ));
  }
}
