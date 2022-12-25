import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitticure/posts.dart';
import 'package:file_picker/file_picker.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});
  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  /// Variables
  File? imageFile;

  /// Widget
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Admin>(context, listen: false).getCurrentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Picker"),
      ),
      body: Container(
          child: imageFile != null
              ? Container(
                  child: Image.file(
                    imageFile!,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          _getFromGallery(user);
                        },
                        child: const Text("PICK FROM GALLERY"),
                      ),
                      Container(
                        height: 40.0,
                      ),
                      if (Platform.isAndroid || Platform.isIOS)
                        ElevatedButton(
                          onPressed: () {
                            _getFromCamera(user);
                          },
                          child: const Text("PICK FROM CAMERA"),
                        )
                    ],
                  ),
                )),
    );
  }

  /// Get from gallery
  _getFromGallery(User? user) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        File file = File(result.files.single.path!);
        if (user != null) {
          user.addPost(Image.file(file));
        }
        imageFile = file;
      });
    }
  }

  /// Get from Camera
  _getFromCamera(User? user) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        if (user != null) {
          user.addPost(Image.file(File(pickedFile.path)));
        }
        imageFile = File(pickedFile.path);
      });
    }
  }
}
