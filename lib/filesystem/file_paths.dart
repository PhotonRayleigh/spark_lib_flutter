import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'package:flutter/foundation.dart';

final SystemPaths systemPaths = SystemPaths.platform();

class SystemPaths {
  /// Usually C:\ on Windows.
  /// / on everything else except iOS.
  /// iOS is currently undefined.
  String get systemRoot {
    return _systemRoot ?? "";
  }

  /// This is for app generated files
  String get applicationStorage {
    return _applicationStorage ?? "";
  }

  /// Either Home on 'nix systems or users on Windows
  String get userDirectory {
    return _userDirectory ?? "";
  }

  String get tempDirectory {
    return _tempDirectory ?? "";
  }

  /// This is for user generated files
  /// Double check that you save to a directory specific to this
  /// app, not in the user's root documents.
  String get documentsDirectory {
    return _documentsDirectory ?? "";
  }

  String get downloadsDirectory {
    return _downloadsDirectory ?? "";
  }

  String? _systemRoot;
  String? _applicationStorage;
  String? _userDirectory;
  String? _tempDirectory;
  String? _documentsDirectory;
  String? _downloadsDirectory;

  Completer completer = Completer();
  late Future<void> ready;

  SystemPaths() {
    ready = completer.future;
    populatePaths();
  }

  factory SystemPaths.platform() {
    if (kIsWeb)
      return SystemPaths();
    else if (Platform.isWindows)
      return WindowsPaths();
    else if (Platform.isMacOS)
      return MacOSPaths();
    else if (Platform.isLinux)
      return LinuxPaths();
    else if (Platform.isAndroid)
      return AndroidPaths();
    else if (Platform.isIOS)
      return IOSPaths();
    else
      return SystemPaths();
  }

  Future<void> populatePaths() async {
    if (kIsWeb) return;

    var env = Platform.environment; // Fetch environment variables
    List<Future> awaiterList = [];

    if (Platform.isMacOS || Platform.isLinux) {
      _systemRoot = "/";
      _userDirectory = env['HOME'] ?? "";

      awaiterList
          .add(getApplicationDocumentsDirectory().then((Directory result) {
        _documentsDirectory = result.path;
      }));

      awaiterList.add(getApplicationSupportDirectory().then((Directory result) {
        _applicationStorage = result.path;
      }));

      awaiterList.add(getDownloadsDirectory().then((Directory? result) {
        _applicationStorage =
            result?.path ?? p.join(_userDirectory! + "/Downloads");
      }));

      awaiterList.add(getTemporaryDirectory().then((Directory result) {
        _tempDirectory = result.path;
      }));
      //
    } else if (Platform.isWindows) {
      _systemRoot = env['SYSTEMDRIVE'] ?? "C:\\";
      _systemRoot = systemRoot + p.separator;
      _userDirectory = env['UserProfile'] ?? "";

      // TODO: Make these accessible
      var programFiles = env['PROGRAMFILES'];
      var programFilesx86 = env['PROGRAMFILES(X86)'];

      // user\Documents
      awaiterList
          .add(getApplicationDocumentsDirectory().then((Directory result) {
        _documentsDirectory = result.path;
      }));

      // Appdata\Roaming\<org_name>\<app_name>
      awaiterList.add(getApplicationSupportDirectory().then((Directory result) {
        _applicationStorage = result.path;
      }));

      // user\Downloads
      awaiterList.add(getDownloadsDirectory().then((Directory? result) {
        _applicationStorage =
            result?.path ?? p.join(_userDirectory! + "/Downloads");
      }));

      // AppData\Local\Temp
      awaiterList.add(getTemporaryDirectory().then((Directory result) {
        _tempDirectory = result.path;
      }));
    } else if (Platform.isAndroid) {
      // IMPORTANT: Android will not show what files are in the filesystem
      // without the filesystem permission, which has to be explicitly granted.
      // Requires request code and app.manifest entry

      _systemRoot = "/";

      _userDirectory = p.join(p.separator, "storage", "emulated", "0");
      var mount = p.join(p.separator, "mnt");
      var system = p.join(p.separator, "system");

      // /data/user/0/<Org name>.<app name>/app_flutter
      // awaiterList
      //     .add(getApplicationDocumentsDirectory().then((Directory result) {
      //   _documentsDirectory = result.path; // TODO: This isn't useful on Android
      // }));

      // /data/user/0/<Org name>.<app name>/files
      awaiterList.add(getApplicationSupportDirectory().then((Directory result) {
        _applicationStorage = result.path;
        // Handle downloads here
        _downloadsDirectory = p.join(_applicationStorage! + "Downloads");
      }));

      // Does not work on Android!
      // awaiterList.add(getDownloadsDirectory().then((Directory? result) {
      //   _applicationStorage =
      //       result?.path ?? p.join(_userDirectory! + "/Downloads");
      // }));

      // /data/user/0/<Org name>.<app name>/files/cache
      awaiterList.add(getTemporaryDirectory().then((Directory result) {
        _tempDirectory = result.path;
      }));

      // /storage/emulated/0/Android/data/<Org name>.<app name>/files
      awaiterList.add(getExternalStorageDirectory().then((Directory? result) {
        _documentsDirectory = result?.path ?? "";
      }));

      // /storage/emulated/0/Android/data/<Org name>.<app name>/files
      awaiterList
          .add(getExternalCacheDirectories().then((List<Directory>? result) {
        var androidCache = result?[0].path ?? ""; // TODO - account for this
      }));
    } else if (Platform.isIOS) {
      // TODO: This is a stub function, needs to be tested against an iOS
      // deployment and completed.

      _systemRoot = "";
      _userDirectory = "";

      awaiterList
          .add(getApplicationDocumentsDirectory().then((Directory result) {
        _documentsDirectory = result.path;
      }));

      awaiterList.add(getApplicationSupportDirectory().then((Directory result) {
        _applicationStorage = result.path;
      }));

      awaiterList.add(getDownloadsDirectory().then((Directory? result) {
        _applicationStorage =
            result?.path ?? p.join(_userDirectory! + "/Downloads");
      }));

      awaiterList.add(getTemporaryDirectory().then((Directory result) {
        _tempDirectory = result.path;
      }));
    }

    await Future.wait(awaiterList);
    completer.complete();
    return;
  }
}

class WindowsPaths extends SystemPaths {
  String get programFiles {
    return _programFiles ?? "";
  }

  String get programFilesx86 {
    return _programFilesx86 ?? "";
  }

  String? _programFiles;
  String? _programFilesx86;

  @override
  Future<void> populatePaths() async {
    var env = Platform.environment; // Fetch environment variables
    List<Future> awaiterList = [];

    _systemRoot = env['SYSTEMDRIVE'] ?? "C:\\";
    _systemRoot = systemRoot + p.separator;
    _userDirectory = env['UserProfile'] ?? "";

    // TODO: Make these accessible
    _programFiles = env['PROGRAMFILES'];
    _programFilesx86 = env['PROGRAMFILES(X86)'];

    // user\Documents
    awaiterList.add(getApplicationDocumentsDirectory().then((Directory result) {
      _documentsDirectory = result.path;
    }));

    // Appdata\Roaming\<org_name>\<app_name>
    awaiterList.add(getApplicationSupportDirectory().then((Directory result) {
      _applicationStorage = result.path;
    }));

    // user\Downloads
    awaiterList.add(getDownloadsDirectory().then((Directory? result) {
      _downloadsDirectory =
          result?.path ?? p.join(_userDirectory! + "/Downloads");
    }));

    // AppData\Local\Temp
    awaiterList.add(getTemporaryDirectory().then((Directory result) {
      _tempDirectory = result.path;
    }));

    await Future.wait(awaiterList);
    completer.complete();
    return;
  }
}

class MacOSPaths extends SystemPaths {
  @override
  Future<void> populatePaths() async {
    var env = Platform.environment; // Fetch environment variables
    List<Future> awaiterList = [];
    _systemRoot = "/";
    _userDirectory = env['HOME'] ?? "";

    awaiterList.add(getApplicationDocumentsDirectory().then((Directory result) {
      _documentsDirectory = result.path;
    }));

    awaiterList.add(getApplicationSupportDirectory().then((Directory result) {
      _applicationStorage = result.path;
    }));

    awaiterList.add(getDownloadsDirectory().then((Directory? result) {
      _applicationStorage =
          result?.path ?? p.join(_userDirectory! + "/Downloads");
    }));

    awaiterList.add(getTemporaryDirectory().then((Directory result) {
      _tempDirectory = result.path;
    }));
    await Future.wait(awaiterList);
    completer.complete();
    return;
  }
}

class LinuxPaths extends SystemPaths {
  @override
  Future<void> populatePaths() async {
    var env = Platform.environment; // Fetch environment variables
    List<Future> awaiterList = [];
    _systemRoot = "/";
    _userDirectory = env['HOME'] ?? "";

    awaiterList.add(getApplicationDocumentsDirectory().then((Directory result) {
      _documentsDirectory = result.path;
    }));

    awaiterList.add(getApplicationSupportDirectory().then((Directory result) {
      _applicationStorage = result.path;
    }));

    awaiterList.add(getDownloadsDirectory().then((Directory? result) {
      _applicationStorage =
          result?.path ?? p.join(_userDirectory! + "/Downloads");
    }));

    awaiterList.add(getTemporaryDirectory().then((Directory result) {
      _tempDirectory = result.path;
    }));
    await Future.wait(awaiterList);
    completer.complete();
    return;
  }
}

class AndroidPaths extends SystemPaths {
  String get mount {
    return _mount ?? "";
  }

  String get system {
    return _system ?? "";
  }

  String get userCache {
    return _userCache ?? "";
  }

  String? _mount;
  String? _system;
  String? _userCache;

  @override
  Future<void> populatePaths() async {
    var env = Platform.environment; // Fetch environment variables
    List<Future> awaiterList = [];

    // IMPORTANT: Android will not show what files are in the filesystem
    // without the filesystem permission, which has to be explicitly granted.
    // Requires request code and app.manifest entry

    _systemRoot = "/";

    _userDirectory = p.join(p.separator, "storage", "emulated", "0");
    _mount = p.join(p.separator, "mnt");
    _system = p.join(p.separator, "system");

    // /data/user/0/<Org name>.<app name>/app_flutter
    // awaiterList
    //     .add(getApplicationDocumentsDirectory().then((Directory result) {
    //   _documentsDirectory = result.path; // TODO: This isn't useful on Android
    // }));

    // /data/user/0/<Org name>.<app name>/files
    awaiterList.add(getApplicationSupportDirectory().then((Directory result) {
      _applicationStorage = result.path;
      // Handle downloads here
      _downloadsDirectory =
          p.join(_applicationStorage! + p.separator + "Downloads");
    }));

    // Does not work on Android!
    // awaiterList.add(getDownloadsDirectory().then((Directory? result) {
    //   _applicationStorage =
    //       result?.path ?? p.join(_userDirectory! + "/Downloads");
    // }));

    // /data/user/0/<Org name>.<app name>/files/cache
    awaiterList.add(getTemporaryDirectory().then((Directory result) {
      _tempDirectory = result.path;
    }));

    // /storage/emulated/0/Android/data/<Org name>.<app name>/files
    awaiterList.add(getExternalStorageDirectory().then((Directory? result) {
      _documentsDirectory = result?.path ?? "";
    }));

    // /storage/emulated/0/Android/data/<Org name>.<app name>/files
    awaiterList
        .add(getExternalCacheDirectories().then((List<Directory>? result) {
      _userCache = result?[0].path ?? "";
    }));

    await Future.wait(awaiterList);
    completer.complete();
    return;
  }
}

class IOSPaths extends SystemPaths {
  @override
  Future<void> populatePaths() async {
    var env = Platform.environment; // Fetch environment variables
    List<Future> awaiterList = [];
    _systemRoot = "";
    _userDirectory = "";

    awaiterList.add(getApplicationDocumentsDirectory().then((Directory result) {
      _documentsDirectory = result.path;
    }));

    awaiterList.add(getApplicationSupportDirectory().then((Directory result) {
      _applicationStorage = result.path;
    }));

    awaiterList.add(getDownloadsDirectory().then((Directory? result) {
      _applicationStorage =
          result?.path ?? p.join(_userDirectory! + "/Downloads");
    }));

    awaiterList.add(getTemporaryDirectory().then((Directory result) {
      _tempDirectory = result.path;
    }));
    await Future.wait(awaiterList);
    completer.complete();
    return;
  }
}
