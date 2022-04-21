import 'file_paths.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:file_selector/file_selector.dart';

/*
    Some initial notes:
    Given the variety of methods operating systems use to control file access,
    I'd rather abstract it away as much as possible.

    First we need to be aware of what platform we're on.
    Second we need to know if we're sandboxed or not.

    Mac can run Sandboxed or not sandboxed.
    iOS is always sandboxed.
    Android uses permissions to access shared storage.
    Windows doesn't care about much of anything.
    Neither does Linux, just don't try to access root stuff
    without sudo.

    I want this class to provide access to system resources and
    transparently (mostly) manage the relevant permissions.

    My model for the filesystem is as follows:
    1) Application data: this is where all app data lives, and
      we rule the roost here. We have full control, but the user
      won't normally see any of the files here (or can't, in the case
      of Android).
    2) The rest of the filesystem. We'll treat this as heavily restricted
      and the user has to provide access most of the time.

    There is also a "Documents" directory where we should be allowed to produce
    user-findable files. This is pretty inconsistant between systems, so
    I'll need to be explicit about where we're saving per platform.

    Provide a defualt, but then probably just let the user pick.
  */
class FileSystemManager {
  static FileSystemManager I = FileSystemManager();
  // Filesystem manager will handle providing paths for file operations
  // as well as handle permissions.
  // The behavior will be different per platform and the platform's parameters.

  bool sandbox = true; // We'll assume yes for now.
  String
      appName; // Replace these later with an environment manager or calls to app or something.
  String orgName;

  // Only application files and temp files are really guarenteed on every system.
  Future<String> get applicationFilesPath async {
    await SystemPaths.I.ready;
    return SystemPaths.I.applicationStorage;
  }

  Future<String> get tempFilesPath async {
    await SystemPaths.I.ready;
    return SystemPaths.I.tempDirectory;
  }

  Future<String> get defaultDocumentsPath async {
    await SystemPaths.I.ready;
    return SystemPaths.I.documentsDirectory;
  }

  FileSystemManager({this.appName = "", this.orgName = ""});

  void config(String appName, String orgName) {
    this.appName = appName;
    this.orgName = orgName;
  }

  Future<String?> getUserPickDirectory() async {
    String? path = await getDirectoryPath();
    return path;
  }

  Future<String> getUserPickFile() async {
    return "";
  }

  Future<String> getUserSavePath() async {
    return "";
  }
}

enum BuildType { debug, release }
