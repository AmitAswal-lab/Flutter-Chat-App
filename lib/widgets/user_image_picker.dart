import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});

  final void Function(File pickedImage) onPickedImage; 

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {

  File? _pickedImageFile;

  void _imagePicker()async{
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 300);

    if(pickedImage == null){
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickedImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          foregroundImage: _pickedImageFile !=null ? FileImage(_pickedImageFile!) : null,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          radius: 40,
        ),
        TextButton.icon(
          onPressed: _imagePicker,
          icon: Icon(Icons.image), 
          label: Text( 
            'Add Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ), 
      ],
    );
  }
}