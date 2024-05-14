import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  String name;

  @HiveField(2)
  String password;

  @HiveField(3)
  List<String>? quickPhrases;

  @HiveField(4)
  String? language;

  @HiveField(5)
  List<String>? quickPhrasesLanguages;

  @HiveField(6)
  Map<String, dynamic>? preferences;

  User(
      this.email,
      this.name,
      this.password, {
        this.quickPhrases,
        this.language,
        this.quickPhrasesLanguages,
        this.preferences,
      });
}