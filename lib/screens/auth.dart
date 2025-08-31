import 'dart:io';

import 'package:chat_app/logic/validator_logic.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formkey = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredpassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;
  bool _isPasswordVisible = false;

  void _submit() async {
    final isValid = _formkey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formkey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredpassword,
        );
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredpassword,
        );

        String imageURL;

        if (_selectedImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${userCredentials.user!.uid}.jpg');

          await storageRef.putFile(_selectedImage!);
          imageURL = await storageRef.getDownloadURL();
        } else {
          final encodedUsername = Uri.encodeComponent(_enteredUsername);
          imageURL =
              'https://ui-avatars.com/api/?name=$encodedUsername&background=random&color=fff&size=128';
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
              'username': _enteredUsername,
              'email': _enteredEmail,
              'imageURL': imageURL,
              'uid': userCredentials.user!.uid,
              'username_lowercase': _enteredUsername.toLowerCase(),
            });
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                child: Image.asset('assets/chat1.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickedImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                              enableSuggestions: false,
                              validator: usernameValidation,
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          const SizedBox(height: 16),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                // Only validate email format on sign-up.
                                return _isLogin ? null : textValidation(value);
                              },
                              onSaved: (newValue) {
                                _enteredEmail = newValue!;
                              },
                            ),
                          const SizedBox(height: 16),
                          if (!_isAuthenticating)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    // Update the state to toggle password visibility
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),

                              obscureText: !_isPasswordVisible,
                              validator: (value) {
                                // Only validate password format on sign-up.
                                return _isLogin
                                    ? null
                                    : passwordValidation(value);
                              },
                              onSaved: (newValue) {
                                _enteredpassword = newValue!;
                              },
                            ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text(_isLogin ? 'Log in' : 'Sign up'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Create an Account'
                                  : 'I already have an account',
                            ),
                          ),
                        ],
                      ),
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
