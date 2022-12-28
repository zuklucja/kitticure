import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitticure/firestore_service.dart';
import 'package:kitticure/storage_service.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});
  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  Image? image;
  User? user = FirebaseAuth.instance.currentUser;
  final Storage storage = Storage();
  final Firestore firestore = Firestore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wstaw nowy post"),
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
                          _getFromCamera(user);
                        },
                        child: const Text("ZAŁADUJ ZDJĘCIE"),
                      )
                    ],
                  ),
                )),
    );
  }

  _getFromCamera(User? user) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      if (user != null) {
        var resultFF =
            await FirebaseFirestore.instance.collection('posts').add({
          'ownerLogin': await firestore.getCurrentUserLogin(user.email),
          'date': DateTime.now(),
        });

        await storage.uploadFile(pickedFile, resultFF.id);
        final url = await storage.downloadUrl(resultFF.id);

        setState(() {
          image = Image.network(url);
        });
      }
    }
  }
}
