import 'package:hive_flutter/hive_flutter.dart';
import 'package:voicecraft/user.dart';

Future<void> initializeHive() async {
  await Hive.initFlutter();
  await Hive.openBox<User>('users');
  await Hive.openBox<String>('loggedInUserEmail');
}