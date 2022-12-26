import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kitticure/storage-service.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});
  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  /// Variables
  Image? image;
  User? user = FirebaseAuth.instance.currentUser;
  final Storage storage = Storage();
  final storageRef = FirebaseStorage.instance.ref();

  /// Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Picker"),
      ),
      body: Container(
          child: image != null
              ? Container(
                  child: image,
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
                      if (kIsWeb)
                        Container()
                      else if (Platform.isAndroid || Platform.isIOS)
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
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      setState(() async {
        if (user != null) {
          var resultFF =
              await FirebaseFirestore.instance.collection('posts').add({
            'ownerLogin': getCurrentUserLogin(user.uid),
            'date': DateTime.now(),
          });

          await storage.uploadFile(result.files.first.name, resultFF.id);
          final url = await storage.downloadUrl(resultFF.id);
          image = Image.network(url);
        }
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
      setState(() async {
        if (user != null) {
          var resultFF =
              await FirebaseFirestore.instance.collection('posts').add({
            'ownerLogin': getCurrentUserLogin(user.uid),
            'date': DateTime.now(),
          });

          await storage.uploadFile(pickedFile.path, resultFF.id);
          final url = await storage.downloadUrl(resultFF.id);
          image = Image.network(url);
        }
      });
    }
  }

  String getCurrentUserLogin(String? uid) {
    if (uid == null) return "";

    String result = "";
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        result = data['login'];
      }
    });
    return result;
  }
}
