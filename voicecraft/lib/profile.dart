import 'package:flutter/material.dart';
import 'package:voicecraft/landing_page.dart';
import 'package:voicecraft/user.dart';
import 'package:voicecraft/user_repository.dart';
import 'package:hive/hive.dart';

class ProfileScreen extends StatefulWidget {
  final UserRepository userRepository;
  const ProfileScreen({Key? key, required this.userRepository})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      user = await widget.userRepository.getLoggedInUser();
      setState(() {});
    } catch (e) {
      // Handle any exceptions that occur during the user retrieval process
      print('Error fetching user: $e');
    }
  }

  String toTitleCase(String input) {
    if (input.isEmpty) {
      return input;
    }

    return input.split(' ').map((word) {
      if (word.isEmpty) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<User?>(
        future: widget.userRepository.getLoggedInUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            user = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xffB7372A),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 80.0,
                              backgroundImage:
                              AssetImage('assets/profile_image.png'),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Center(
                            child: Text(
                              toTitleCase(user!.name),
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Center(
                            child: Text(
                              user!.email,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                          SizedBox(height: 24.0),
                          Center(
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Color(0xFFF5E5E5),
                                      title: Text(
                                        'Terms and Conditions',
                                        style: TextStyle(
                                          color: Color(0xffB7372A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: Text(
                                          'Welcome to Voicecraft! Please read these terms and conditions carefully before using our app.\n\n'
                                              '1. Audio Recording\n'
                                              'Voicecraft does not save any audio that is recorded within the app. We respect your privacy and ensure that all audio data is processed in real-time and not stored on our servers or any third-party services.\n\n'
                                              '2. Permission and Background Recording\n'
                                              'Voicecraft only records audio when you explicitly grant permission to the app. We do not record audio without your consent or in the background. The app will only capture audio when you actively initiate the recording process.\n\n'
                                              '3. User Preferences and Information\n'
                                              'All user preferences and settings within Voicecraft are kept strictly confidential. We do not share or sell any of your personal information, including your name, email address, or any other data you provide, to advertisers or third parties. Your privacy is of utmost importance to us.\n\n'
                                              '4. Intellectual Property\n'
                                              'Voicecraft and all its contents, including but not limited to text, graphics, logos, images, and software, are the property of Voicecraft and are protected by copyright, trademark, and other intellectual property laws. You may not modify, reproduce, distribute, or create derivative works based on the app without our prior written consent.\n\n'
                                              '5. Limitation of Liability\n'
                                              'Voicecraft is provided on an "as is" and "as available" basis. We do not guarantee that the app will be uninterrupted, error-free, or free from viruses or other harmful components. In no event shall Voicecraft be liable for any direct, indirect, incidental, consequential, or punitive damages arising out of or in connection with your use of the app.\n\n'
                                              '6. Changes to Terms and Conditions\n'
                                              'We reserve the right to modify or update these terms and conditions at any time without prior notice. It is your responsibility to review this page periodically for any changes. Your continued use of Voicecraft after any modifications constitute your acceptance of the revised terms and conditions.\n\n'
                                              'By using Voicecraft, you agree to be bound by these terms and conditions. If you do not agree with any part of these terms, please refrain from using our app.\n\n'
                                              '© 2024 Voicecraft. All rights reserved.',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'OK',
                                            style: TextStyle(
                                                color: Color(0xffB7372A)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Terms & Condition',
                                style: TextStyle(
                                    fontSize: 16.0, color: Color(0xffB7372A)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        await widget.userRepository.logout();
                        await Hive.deleteBoxFromDisk('quickPhrases');
                        await Hive.deleteBoxFromDisk('selectedLanguage');
                        await Hive.deleteBoxFromDisk('quickPhrasesLanguages');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LandingPage()),
                              (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xffB7372A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text('No user found'));
          }
        },
      ),
    );
  }
}