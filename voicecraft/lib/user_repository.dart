import 'package:hive/hive.dart';
import 'package:voicecraft/user.dart';

class UserRepository {
  static final UserRepository _singleton = UserRepository._internal();

  factory UserRepository() {
    return _singleton;
  }

  UserRepository._internal();

  Future<void> addUser(User user) async {
    final box = Hive.box<User>('users');
    await box.put(user.email, user);
  }

  Future<User?> getUser(String email, String password) async {
    final box = Hive.box<User>('users');
    final user = box.get(email);
    if (user != null && user.password == password) {
      final emailBox = Hive.box<String>('loggedInUserEmail');
      await emailBox.put('email', email);
      return user;
    }
    return null;
  }

  Future<User?> getLoggedInUser() async {
    final emailBox = Hive.box<String>('loggedInUserEmail');
    final email = emailBox.get('email');
    if (email != null) {
      final box = Hive.box<User>('users');
      return box.get(email);
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    final box = Hive.box<User>('users');
    await box.put(user.email, user);
  }

  Future<void> logout() async {
    final emailBox = Hive.box<String>('loggedInUserEmail');
    await emailBox.delete('email');
  }
}