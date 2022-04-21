import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PermissionManager {
  Future<bool> requestStoragePermission() async {
    if (!kIsWeb && Platform.isWindows || Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        print("Storage permission granted");
        return true;
      } else {
        print("Storage permission denied");
        return false;
      }
    } else {
      throw UnimplementedError(
          "Storage permissions are not yet implemented for this platform.");
    }
  }
}
