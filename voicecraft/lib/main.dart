import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:voicecraft/user.dart';
import 'package:voicecraft/landing_page.dart';
import 'package:voicecraft/hive_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.registerAdapter(UserAdapter());
  await initializeHive();
  await Hive.openBox<List<String>>('quickPhrases');
  await Hive.openBox<String>('selectedLanguage');
  await Hive.openBox<List<String>>('quickPhrasesLanguages');
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xffB7372A)),
        ),
      ),
      home: LandingPage(),
    );
  }
}