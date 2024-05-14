import 'package:flutter/material.dart';
import 'package:voicecraft/speech_screen.dart';
import 'package:voicecraft/user.dart';
import 'package:voicecraft/user_repository.dart';
import 'package:hive/hive.dart';

class SignUpPage extends StatefulWidget {
  final UserRepository userRepository;

  SignUpPage({required this.userRepository});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
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
              TextField(
                controller: confirmPasswordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
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
                  child: Text('Sign Up'),
                  onPressed: () async {
                    String name = nameController.text;
                    String email = emailController.text;
                    String password = passwordController.text;
                    String confirmPassword = confirmPasswordController.text;

                    String pattern = r'^.+@.+\..+$';
                    RegExp regex = RegExp(pattern);

                    List<String> errors = [];

                    if (name.isEmpty) {
                      errors.add('Please enter your name');
                    }

                    if (!regex.hasMatch(email)) {
                      errors.add('Please enter a valid email');
                    }

                    if (password.isEmpty) {
                      errors.add('Please enter a password');
                    }

                    if (confirmPassword.isEmpty) {
                      errors.add('Please confirm your password');
                    }

                    if (password != confirmPassword) {
                      errors.add('Passwords do not match');
                    }

                    if (errors.isNotEmpty) {
                      setState(() {
                        _validationMessages = errors.join('\n');
                      });
                      return;
                    }

                    User newUser = User(email, name, password);
                    await widget.userRepository.addUser(newUser);

                    // Store the new user's email in the 'loggedInUserEmail' Hive box
                    final emailBox =
                        await Hive.openBox<String>('loggedInUserEmail');
                    await emailBox.put('email', email);

                    // Navigate to the SpeechScreen with the new user's data
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpeechScreen(
                          userName: name,
                          userRepository: widget.userRepository,
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.orange),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
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
