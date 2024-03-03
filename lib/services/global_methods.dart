import 'package:flutter/cupertino.dart';
import 'package:showtime/screens/browse.dart';

class GlobalMethods {
  static navigateTo(
      {required BuildContext context, required String routeName}) {
    Navigator.pushNamed(context, routeName);
  }
}
