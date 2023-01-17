import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kitticure/services/firestore_service.dart';
import 'package:kitticure/services/storage_service.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});
  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  Image? image;
  final User? user = FirebaseAuth.instance.currentUser;
  final Storage storage = Storage();
  final Firestore firestore = Firestore();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Wstaw nowy post"),
        ),
        body: Container(
            child: image != null
                ? Center(
                    child: Column(children: [
                      const Text("Załadowano zdjęcie:"),
                      Container(child: image),
                    ]),
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
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("ZAŁADUJ ZDJĘCIE",
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        if (!kIsWeb)
                          ElevatedButton(
                            onPressed: () {
                              _getFromCamera(user);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("ZRÓB ZDJĘCIE APARATEM",
                                  style: TextStyle(fontSize: 18)),
                            ),
                          )
                      ],
                    ),
                  )),
      ),
    );
  }

  _getFromCamera(User? user) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    _addPickedFileToDatabase(pickedFile, user);
  }

  _getFromGallery(User? user) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    _addPickedFileToDatabase(pickedFile, user);
  }

  _addPickedFileToDatabase(XFile? pickedFile, User? user) async {
    if (pickedFile != null) {
      if (user != null && user.email != null) {
        var id = await firestore.addNewPost(user.email!);

        await storage.uploadFile(pickedFile, id);
        final String url = await storage.downloadUrl(id);

        firestore.updateNewPostPhotoURL(id, url);

        setState(() {
          image = Image.network(url);
        });
      }
    }
  }
}
