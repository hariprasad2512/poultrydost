import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:showtime/screens/user_auth/phone.dart';
import 'package:showtime/screens/user_auth/success_message.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_database/firebase_database.dart';

class MyOtp extends StatefulWidget {
  MyOtp({super.key, this.phone_number});
  late String? phone_number;

  @override
  State<MyOtp> createState() => _MyOtpState();
}

class _MyOtpState extends State<MyOtp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  final List<num> watchedList = [];
  final List<num> watchList = [];
  Future<void> saveUser() async {
    // final currentUser = FirebaseAuth.instance.currentUser;
    // FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).set({
    //   "phone_number": widget.phone_number,
    //   "watchedList": watchedList,
    //   "watchList": watchList
    // });
    //
    // print("Saved User data");
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      // User already exists in Firestore, retrieve watchedList and watchList arrays
      final userData = userSnapshot.data() as Map<String, dynamic>;
      watchedList
          .addAll((userData['watchedList'] as List<dynamic>).cast<num>());
      watchList.addAll((userData['watchList'] as List<dynamic>).cast<num>());
    } else {
      // User does not exist in Firestore, create a new document
      await userRef.set({
        "watchedList": watchedList,
        "watchList": watchList,
      });
    }

    print("Saved User data");
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = brightness == Brightness.dark;
    final defaultPinTheme = PinTheme(
      width: 45,
      height: 45,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    var code = "";
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: FaIcon(
                FontAwesomeIcons.chevronLeft,
                color: isDarkMode ? Colors.white : Colors.black54,
              ))),
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Phone Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'We need to register your device phone before getting started',
                style: TextStyle(
                  fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Pinput(
                //defaultPinTheme: defaultPinTheme,
                // focusedPinTheme: focusedPinTheme,
                // submittedPinTheme: submittedPinTheme,
                length: 6,
                showCursor: true,
                onChanged: (value) {
                  code = value;
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Create a PhoneAuthCredential with the code
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                              verificationId: MyPhone.verify, smsCode: code);

                      // Sign the user in (or link) with the credential
                      await auth.signInWithCredential(credential);
                      saveUser();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SuccessMessage(
                                    watchedList: watchedList,
                                    watchList: watchList,
                                  )));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Signed In Successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      print("Wrong OTP");
                    }
                  },
                  child: Text('Verify Phone Number'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, 'phone', (route) => false);
                    },
                    child: Text(
                      'Edit Phone Number?',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
