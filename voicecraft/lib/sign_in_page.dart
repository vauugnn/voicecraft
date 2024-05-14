import 'package:flutter/material.dart';
import 'package:voicecraft/speech_screen.dart';
import 'package:voicecraft/user.dart';
import 'package:voicecraft/user_repository.dart';

class SignInPage extends StatefulWidget {
  final UserRepository userRepository;

  SignInPage({required this.userRepository});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  String _validationMessages = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              Center(
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  suffix: InkWell(
                    onTap: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    child: Text(
                      hidePassword ? 'Show' : 'Hide',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  child: Text('Sign In'),
                  onPressed: () async {
                    String email = emailController.text.trim();
                    String password = passwordController.text;

                    if (email.isEmpty || password.isEmpty) {
                      setState(() {
                        _validationMessages = 'Please enter email and password';
                      });
                      return;
                    }

                    try {
                      User? user = await widget.userRepository.getUser(email, password);
                      if (user != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpeechScreen(
                              userName: user.name,
                              userRepository: widget.userRepository,
                            ),
                          ),
                        );
                      } else {
                        setState(() {
                          _validationMessages = 'Invalid email or password';
                        });
                      }
                    } catch (e) {
                      print('Error during sign-in: $e');
                      setState(() {
                        _validationMessages = 'An error occurred. Please try again.';
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xffB7372A)),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    minimumSize: MaterialStateProperty.all<Size>(Size(300, 55)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Center(
                  child: Text(
                    _validationMessages,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}