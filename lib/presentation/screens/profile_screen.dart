import 'dart:io';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final _usernameController = TextEditingController();
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? newImageURL;

      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${_currentUser.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        newImageURL = await storageRef.getDownloadURL();
      }

      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(_currentUser.uid);

      final updates = <String, dynamic>{
        'username': _usernameController.text.trim(),
        'username_lowercase': _usernameController.text.trim().toLowerCase(),
      };

      if (newImageURL != null) {
        updates['imageURL'] = newImageURL;
      }

      await userDocRef.update(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(); // Go back to the previous screen
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Could not load user data.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          _usernameController.text = userData['username'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                UserImagePicker(
                  initialImageURL: userData['imageURL'],
                  onPickedImage: (pickedImage) {
                    _selectedImage = pickedImage;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 24),
                if (_isSaving)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Changes'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
