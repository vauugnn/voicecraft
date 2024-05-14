import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:voicecraft/speech_screen.dart';
import 'package:voicecraft/user_repository.dart';
import 'package:voicecraft/landing_page.dart';
import 'package:voicecraft/user.dart';
import 'package:voicecraft/profile.dart';

class TextToSpeechScreen extends StatefulWidget {
  final UserRepository userRepository;

  const TextToSpeechScreen({Key? key, required this.userRepository})
      : super(key: key);

  @override
  TextToSpeechScreenState createState() => TextToSpeechScreenState();
}

class TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final TextEditingController textController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();
  List<String> quickPhrases = ['', '', '', '', '', ''];
  List<String> quickPhrasesLanguages = [
    'en-US',
    'en-US',
    'en-US',
    'en-US',
    'en-US',
    'en-US'
  ];
  String selectedLanguage = 'en-US';
  List<String> availableLanguages = ['en-US', 'fil-PH'];

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage(selectedLanguage);
    _loadPreferences();
  }

  void _loadPreferences() async {
    final user = await widget.userRepository.getLoggedInUser();
    if (user != null) {
      setState(() {
        quickPhrases = user.quickPhrases ?? ['', '', '', '', '', ''];
        selectedLanguage = user.language ?? 'en-US';
        quickPhrasesLanguages = user.quickPhrasesLanguages ??
            ['en-US', 'en-US', 'en-US', 'en-US', 'en-US', 'en-US'];
      });
    }
  }

  void _changeLanguage(String? language) {
    setState(() {
      selectedLanguage = language!;
      flutterTts.setLanguage(language);
    });
    _savePreferences();
  }

  Future<void> _savePreferences() async {
    final user = await widget.userRepository.getLoggedInUser();
    if (user != null) {
      user.quickPhrases = quickPhrases;
      user.language = selectedLanguage;
      user.quickPhrasesLanguages = quickPhrasesLanguages;
      await widget.userRepository.updateUser(user);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _savePreferences();
        return true;
      },
      child: FutureBuilder<User?>(
        future: widget.userRepository.getLoggedInUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final user = snapshot.data;
            return Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                  userRepository: widget.userRepository,
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                            AssetImage('assets/profile_image.png'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome! ${getFirstName(user?.name ?? '')}',
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: textController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Enter text',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            textController.clear();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Select Language:',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedLanguage,
                          onChanged: _changeLanguage,
                          items: availableLanguages.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: _speak,
                          child: Image.asset(
                            'assets/speak_button.png',
                            width: 60.0,
                            height: 60.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: quickPhrases.length,
                      itemBuilder: (context, index) {
                        return buildQuickPhrase(index);
                      },
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Long press to add quick phrase',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xffB7372A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Container(),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Open microphone',
                        style:
                        TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildQuickPhrase(int index) {
    return InkWell(
      onTap: () {
        _speakQuickPhrase(index);
      },
      onLongPress: () {
        _showEditDialog(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5E5E5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            quickPhrases[index].isNotEmpty ? quickPhrases[index] : 'Add Phrase',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xffB7372A)),
          ),
        ),
      ),
    );
  }

  Future<void> _speak() async {
    String text = textController.text;
    if (text.isNotEmpty) {
      await flutterTts.setLanguage(selectedLanguage);
      await flutterTts.speak(text);
    }
  }

  Future<void> _speakQuickPhrase(int index) async {
    String text = quickPhrases[index];
    String language = quickPhrasesLanguages[index];
    if (text.isNotEmpty) {
      await flutterTts.setLanguage(language);
      await flutterTts.speak(text);
    }
  }

  void _showEditDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String phraseText = quickPhrases[index];
        String selectedPhraseLanguage = quickPhrasesLanguages[index];
        return AlertDialog(
          backgroundColor: Color(0xFFF5E5E5),
          title: const Text(
            'Add Quick Phrase',
            style: TextStyle(
              color: Color(0xffB7372A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: phraseText),
                onChanged: (value) {
                  phraseText = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter phrase or word',
                ),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedPhraseLanguage,
                onChanged: (String? newValue) {
                  selectedPhraseLanguage = newValue!;
                },
                items: availableLanguages.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xffB7372A)),
              ),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  quickPhrases[index] = phraseText;
                  quickPhrasesLanguages[index] = selectedPhraseLanguage;
                });
                await _savePreferences();
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xffB7372A)),
              ),
            ),
          ],
        );
      },
    );
  }
}

String getFirstName(String fullName) {
  if (fullName.isEmpty) {
    return '';
  }

  List<String> nameParts = fullName.split(' ');
  return toTitleCase(nameParts[0]);
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