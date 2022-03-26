import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spark_lib/spark_di.dart';

import '../filesystem/file_paths.dart';
import 'app/app_system_manager.dart';
import 'app/spark_app.dart';
import 'navigation/app_navigator.dart';

export 'app/app_system_manager.dart';
export 'app/spark_app.dart';
export 'navigation/app_navigator.dart';
export 'custom_window/window_appbar.dart';
export 'custom_window/window_data.dart';
export 'navigation/spark_page.dart';

class SparkDIModule {
  /// Registers [SparkApp], [AppSystemManager] [Key], and [SystemPaths] to [GetIt].
  /// Dependencies defined in constructor.
  void initialize(
      {required AppNavigator navigator,
      required Widget home,
      ThemeData? theme,
      String? title,
      AppSystemManagerFactory? systemManagerBuilder,
      GlobalKey<AppSystemManagerState>? sysManagerKey,
      WindowData? windowData}) {
    // IMPORTANT: SystemPaths which relys on PathProvider which relies
    // on Flutter stuff requires that WidgetsFlutterBinding is initialized.
    WidgetsFlutterBinding.ensureInitialized();
    // Make sure SystemPaths is available to the program.
    GetIt.I.registerSingleton<SystemPaths>(SystemPaths());

    // Register the application root.
    GetIt.I.registerSingleton<SparkApp>(
      SparkApp(
          navigator: navigator,
          home: home,
          theme: theme,
          title: title,
          systemManagerBuilder: systemManagerBuilder ??
              ({Key? key, required Widget child}) {
                return AppSystemManager(
                  key: key,
                  child: child,
                );
              },
          sysManagerKey: sysManagerKey,
          windowData: windowData),
    );

    // Make the SystemManager key available if it was not provided.
    if (sysManagerKey == null)
      GetIt.I.registerSingleton<GlobalKey<AppSystemManagerState>>(
          GetIt.I.get<SparkApp>().sysManagerKey);

    return;
  }
}
