import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:showtime/screens/user_auth/otp.dart';
import 'package:showtime/screens/user_auth/success_message.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import '../../services/utils.dart';

class MyPhone extends StatefulWidget {
  const MyPhone({super.key});
  static String verify = "";

  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final fi = FirebaseFirestore.instance;
  final List<num> watchedList = [];
  final List<num> watchList = [];
  int? _resendToken;
  late String _verificationId;
  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  var phone = "";
  TextEditingController countrycode = TextEditingController();

  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );

    try {
      GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        final _gAuth = await account.authentication;
        final _credential = GoogleAuthProvider.credential(
          idToken: _gAuth.idToken,
          accessToken: _gAuth.accessToken,
        );

        await auth.signInWithCredential(_credential);
        await saveUser(account);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SuccessMessage(
                      email: account.email,
                      watchedList: watchedList,
                      watchList: watchList,
                    )));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signed In Successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveUser(GoogleSignInAccount account) async {
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
        "email": account.email,
        "name": account.displayName,
        "profilePic": account.photoUrl,
        "watchedList": watchedList,
        "watchList": watchList,
      });
    }

    print("Saved User data");
  }

  @override
  void initState() {
    // TODO: implement initState
    countrycode.text = "+91";
  }

  @override
  Widget build(BuildContext context) {
    final size = Utils(context).getScreenSize;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'We need to register your device phone before getting started',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    //SizedBox(width: isDarkMode ? 15 : 15),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: countrycode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkMode ? Colors.white : Colors.white,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Text(
                      '|',
                      style: TextStyle(
                        // backgroundColor:
                        //     isDarkMode ? Colors.white : Colors.black,
                        fontSize: 33,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                        child: TextField(
                      onChanged: (value) => {phone = value},
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autofocus: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDarkMode ? Colors.white : Colors.white,
                        border: InputBorder.none,
                        hintText: "Phone Number",
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: '${countrycode.text + phone}',
                      verificationCompleted:
                          (PhoneAuthCredential credential) {},
                      verificationFailed: (FirebaseAuthException e) {
                        print(e);
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        MyPhone.verify = verificationId;
                        _verificationId = verificationId;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyOtp(
                                      phone_number:
                                          '${countrycode.text + phone}',
                                    )));
                        _resendToken = resendToken;
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                  },
                  child: Text('Get OTP'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              SocialLoginButton(
                  textColor: isDarkMode ? Colors.black : Colors.black,
                  backgroundColor: isDarkMode ? Colors.white : Colors.white,
                  buttonType: SocialLoginButtonType.google,
                  onPressed: () {
                    signInWithGoogle();
                    print("Google Sign In Clicked!");
                  })
            ],
          ),
        ),
      ),
    );
  }
}
