import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile({
    required String path,
    required String fileName,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child(path).child(fileName);

      UploadTask uploadTask;
      if (kIsWeb) {
        // For web, use putData if we have bytes, but File in Flutter web is different
        // In this app, we usually have a path from image_picker
        throw UnimplementedError(
          "Web upload needs specific implementation if path is used",
        );
      } else {
        uploadTask = ref.putFile(file);
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  Future<String> uploadData({
    required String path,
    required String fileName,
    required Uint8List data,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref().child(path).child(fileName);
      final metadata = SettableMetadata(contentType: contentType);

      final uploadTask = ref.putData(data, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }
}
