import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:showtime/api/firebase_api.dart';
import 'package:showtime/common/api_client.dart';
import 'package:showtime/data/movie_remote_data_source.dart';
import 'package:showtime/screens/bottom_bar.dart';
import 'package:showtime/screens/browse.dart';
import 'package:showtime/screens/home_screen.dart';
import 'package:showtime/screens/splash_video.dart';
import 'package:showtime/screens/user_auth/otp.dart';
import 'package:showtime/screens/user_auth/phone.dart';
import 'package:showtime/screens/user_auth/success_message.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp();
  FirebaseMessagingService messagingService = FirebaseMessagingService();
  await messagingService.setupFirebaseMessaging();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  late List<num> watchedList = [];
  late List<num> watchList = [];

  // This widget is the root of your application.
  FirebaseAuth auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('users');

  Future<void> connectFirebase() async {
    if (auth.currentUser != null) {
      //   final documentId = auth.currentUser?.uid;
      //   final snapshot = await _collection.doc(auth.currentUser?.uid).get();
      //   if (snapshot.exists) {
      //     final data = snapshot.data();
      //     final arrayField = data!['watchedList'] as List<num>;
      //     final arrayField2 = data!['watchList'] as List<num>;
      //     watchedList = arrayField;
      //     watchList = arrayField2;
      //   }

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        // User already exists in Firestore, retrieve watchedList and watchList arrays
        final userData = userSnapshot.data() as Map<String, dynamic>;
        watchedList
            .addAll((userData['watchedList'] as List<dynamic>).cast<num>());
        watchList.addAll((userData['watchList'] as List<dynamic>).cast<num>());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ApiClient apiClient = ApiClient(Client());
    MovieRemoteDataSource dataSource = MovieRemoteDataSourceImpl(apiClient);
    connectFirebase();

    //return SplashVideo();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashVideo(),
        routes: {
          'phone': (context) => MyPhone(),
          'otp': (context) => MyOtp(),
          'home': (context) => BottomBarScreen(
                watchedList: watchedList,
                watchList: watchList,
                languageString: 'te',
              ),
        });
  }
}
