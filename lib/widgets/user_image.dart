import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImage extends StatefulWidget {
  const UserImage({super.key, required this.imageFunc});
  final void Function(File image) imageFunc;

  @override
  State<UserImage> createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  File? pickedImage;

  void pickImage() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.camera, maxWidth: 150, imageQuality: 50);
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
        widget.imageFunc(pickedImage!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              (pickedImage != null) ? FileImage(pickedImage!) : null,
        ),
        TextButton.icon(
          onPressed: pickImage,
          label: const Text("Select Image"),
        ),
      ],
    );
  }
}
