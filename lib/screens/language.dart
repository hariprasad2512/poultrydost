import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:showtime/screens/home_screen.dart';

import 'bottom_bar.dart';

class LanguageScreen extends StatefulWidget {
  final List<num> watchedList;
  final List<num> watchList;
  LanguageScreen({required this.watchedList, required this.watchList});
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Hindi', 'code': 'hi'},
    {'name': 'Telugu', 'code': 'te'},
    {'name': 'Tamil', 'code': 'ta'},
    {'name': 'Kannada', 'code': 'kn'},
    {'name': 'Malayalam', 'code': 'ml'},
    //{'name': 'Marathi', 'code': 'mr'},
    // Add more languages with their codes as needed
  ];

  List<String> selectedLanguages = [];

  String generateTMDBLanguageCode() {
    return selectedLanguages.join('|');
  }

  var brightness =
      SchedulerBinding.instance.platformDispatcher.platformBrightness;

  void updateSelectedLanguages(String languageCode, bool isChecked) {
    setState(() {
      if (isChecked) {
        selectedLanguages.add(languageCode);
      } else {
        selectedLanguages.remove(languageCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('Change Language of Content'),
        backgroundColor: isDarkMode ? Colors.black : Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          final isChecked = selectedLanguages.contains(language['code']);

          return CheckboxListTile(
            title: Text(
              language['name']!,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            value: isChecked,
            checkColor: Colors.blueAccent,
            fillColor: MaterialStateProperty.all(Colors.white),
            onChanged: (bool? value) {
              updateSelectedLanguages(language['code']!, value ?? false);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Perform any action you need when the user saves the language selection
          String tmdbLanguageCode = generateTMDBLanguageCode();
          // You can save the generated 'tmdbLanguageCode' and use it as needed
          print('TMDB Language Code: $tmdbLanguageCode');

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => BottomBarScreen(
                      languageString: tmdbLanguageCode,
                      watchedList: widget.watchedList,
                      watchList: widget.watchList)),
              (route) => false);
        },
        label: Text('Save'),
        icon: Icon(Icons.save),
      ),
    );
  }
}
