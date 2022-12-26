import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);

    try {
      await storage.ref().child(fileName).putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<String> downloadUrl(String imageName) async {
    String downloadUrl = await storage.ref().child(imageName).getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteFile(String fileName) async {
    await storage.ref().child(fileName).delete();
  }
}
