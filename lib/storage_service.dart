import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadFile(XFile file, String fileName) async {
    Uint8List imageData = await file.readAsBytes();

    try {
      storage.ref().child(fileName).putData(
            imageData,
            SettableMetadata(contentType: 'image/png'),
          );
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