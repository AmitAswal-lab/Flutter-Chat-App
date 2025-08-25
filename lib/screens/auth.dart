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
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredpassword = '';
  var _isAuthenticating = false;
  var _enteredUsername = '';

  final _formkey = GlobalKey<FormState>();

  File? _selectedImage;

  void _sumbit() async {
    final isvalid = _formkey.currentState!.validate();

    if (!isvalid || !_isLogin && _selectedImage == null) {
      return;
    }

    _formkey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredpassword,
        );
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredpassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageURL = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
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
      if (error.code == 'email-already-in-use') {}
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed')),
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
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                child: Image.asset('assets/chat1.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
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
                              validator: (value){
                                return usernameValidation(value);
                              }, 
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          SizedBox(height: 16),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                return textValidation(value);
                              },
                              onSaved: (newValue) {
                                _enteredEmail = newValue!;
                              },
                            ),
                          SizedBox(height: 16),
                          if (!_isAuthenticating)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                return passwordValidation(value);
                              },
                              onSaved: (newValue) {
                                _enteredpassword = newValue!;
                              },
                            ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _sumbit,
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
                                  ? 'Create a Account'
                                  : 'I Already have an Account',
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
