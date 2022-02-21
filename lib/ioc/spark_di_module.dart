import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';

import 'app/app_system_manager.dart';
import 'app/spark_app.dart';
import 'navigation/app_navigator.dart';

export 'app/app_system_manager.dart';
export 'app/spark_app.dart';
export 'navigation/app_navigator.dart';
export 'custom_window/window_appbar.dart';
export 'navigation/spark_page.dart';

class SparkDIModule {
  Injector initialize(Injector injector,
      {required AppNavigator navigator,
      required Widget home,
      ThemeData? theme,
      String? title,
      AppSystemManagerFactory? systemManagerBuilder,
      GlobalKey<AppSystemManagerState>? sysManagerKey}) {
    injector.map<AppSystemManagerFactory>((i) =>
        systemManagerBuilder ??
        ({Key? key, required Widget child}) {
          return AppSystemManager(
            key: key,
            child: child,
          );
        });

    // Widget home = homeFactory();

    // injector.map<AppNavigator>((i) => AppNavigator(home: home),
    //     isSingleton: true);

    injector.map<SparkApp>(
        (i) => SparkApp(
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
            sysManagerKey: sysManagerKey),
        isSingleton: true);

    if (sysManagerKey == null)
      injector.map<GlobalKey<AppSystemManagerState>>(
          (i) => i.get<SparkApp>().sysManagerKey);

    return injector;
  }
}
