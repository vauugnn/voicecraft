import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voicecraft/profile.dart';
import 'package:voicecraft/text_screen.dart';
import 'package:voicecraft/user_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechScreen extends StatefulWidget {
  final String userName;
  final UserRepository userRepository;

  const SpeechScreen({required this.userName, required this.userRepository});

  @override
  SpeechScreenState createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    print('Listen method called');
    if (await Permission.microphone.request().isGranted) {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          setState(() {
            _isListening = true;
            print('Listening started');
          });
          _speech.listen(
            onResult: (val) => setState(() {
              _text = val.recognizedWords;
              print('Recognized words: $_text');
            }),
          );
        }
      } else {
        setState(() {
          _isListening = false;
          print('Listening stopped');
        });
        _speech.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    backgroundImage: AssetImage('assets/profile_image.png'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome! ${getFirstName(widget.userName)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Text(
              _text,
              style: TextStyle(fontSize: 18, color: Color(0xffB7372A)),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: _listen,
              child: Image.asset(
                _isListening
                    ? 'assets/listen_button.png'
                    : 'assets/listen_button.png',
                width: _isListening ? 200.0 : 180.0,
                height: _isListening ? 200.0 : 180.0,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TextToSpeechScreen(
                      userRepository: widget.userRepository,
                    ),
                  ),
                );
              },
              child: Text(
                'Open keyboard',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildQuickPhrase(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xffF5E5E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Color(0xffB7372A)),
      ),
    );
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

String getFirstName(String fullName) {
  if (fullName.isEmpty) {
    return '';
  }

  List<String> nameParts = fullName.split(' ');
  return toTitleCase(nameParts[0]);
}