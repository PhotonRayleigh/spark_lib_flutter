import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Prefer using the app manager in the Program class per project.
late final AppSystemManagerState baseAppManager;

class AppSystemManager extends StatefulWidget {
  final Widget child;
  AppSystemManager({Key? key, required this.child}) : super(key: key);

  @override
  AppSystemManagerState createState() {
    return AppSystemManagerState();
  }
}

class AppSystemManagerState extends State<AppSystemManager>
    with WidgetsBindingObserver {
  static bool _managerSet = false;

  AppSystemManagerState() {
    if (_managerSet)
      throw Exception(
          "Error: Apps can only have one AppSystemManager instanced");
    baseAppManager = this;
  }

  List<void Function()> _onScreenChanged = <void Function()>[];

  void addScreenChanged(void Function() callback) {
    // prevent duplicate entries
    if (_onScreenChanged.contains(callback))
      return;
    else
      _onScreenChanged.add(callback);
  }

  void removeScreenChanged(void Function() callback) =>
      _onScreenChanged.remove(callback);

  List<void Function()> _onLifecycleInactive = [];

  void addLifecycleInactive(void Function() callback) {
    // prevent duplicate entries
    if (_onLifecycleInactive.contains(callback))
      return;
    else
      _onLifecycleInactive.add(callback);
  }

  void removeLifecycleInactive(void Function() callback) =>
      _onLifecycleInactive.remove(callback);

  List<void Function()> _onLifecyclePaused = [];

  void addLifecyclePaused(void Function() callback) {
    // prevent duplicate entries
    if (_onLifecyclePaused.contains(callback))
      return;
    else
      _onLifecyclePaused.add(callback);
  }

  void removeLifecyclePaused(void Function() callback) =>
      _onLifecyclePaused.remove(callback);

  List<void Function()> _onLifecycleResumed = [];
  void addLifecycleResumed(void Function() callback) {
    // prevent duplicate entries
    if (_onLifecycleResumed.contains(callback))
      return;
    else
      _onLifecycleResumed.add(callback);
  }

  void removeLifecycleResumed(void Function() callback) =>
      _onLifecycleResumed.remove(callback);

  List<void Function()> _onLifecycleDetached = [];
  void addLifecycleDetached(void Function() callback) {
    // prevent duplicate entries
    if (_onLifecycleDetached.contains(callback))
      return;
    else
      _onLifecycleDetached.add(callback);
  }

  void removeLifecycleDetached(void Function() callback) =>
      _onLifecycleDetached.remove(callback);

  List<void Function(AppLifecycleState state)> _onLifecycleChanged = [];

  void addLifecycleChanged(void Function(AppLifecycleState state) callback) {
    // prevent duplicate entries
    if (_onLifecycleChanged.contains(callback))
      return;
    else
      _onLifecycleChanged.add(callback);
  }

  void removeLifecycleChanged(
          void Function(AppLifecycleState state) callback) =>
      _onLifecycleChanged.remove(callback);

  List<void Function()> _onLowMemory = [];
  void addLowMemory(void Function() callback) {
    // prevent duplicate entries
    if (_onLowMemory.contains(callback))
      return;
    else
      _onLowMemory.add(callback);
  }

  void removeLowMemory(void Function() callback) =>
      _onLowMemory.remove(callback);

  List<void Function()> _onDispose = [];
  void addDispose(void Function() callback) {
    // prevent duplicate entries
    if (_onDispose.contains(callback))
      return;
    else
      _onDispose.add(callback);
  }

  void removeDispose(void Function() callback) => _onDispose.remove(callback);

  @override
  initState() {
    // Use init state for system initialization tasks, I think
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    for (var action in _onDispose) action();
    // Clean up operations can go in the dispose section
    WidgetsBinding.instance!.removeObserver(this);
    super
        .dispose(); // Remember super.dispose always comes last in dispose methods.
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // The cases provided by Flutter don't cover all system possibilities.
    // For example, if the app is terminated, I might need to write some
    // finalizing code in Kotlin for Android, and might need something special
    // in Swift for iOS.
    switch (state) {
      case AppLifecycleState.inactive:
        print('inactive');
        for (var action in _onLifecycleInactive) action();
        break;
      case AppLifecycleState.paused:
        print('paused');
        for (var action in _onLifecyclePaused) action();
        break;
      case AppLifecycleState.resumed:
        print('resumed');
        for (var action in _onLifecycleResumed) action();
        break;
      case AppLifecycleState.detached:
        print('detached');
        for (var action in _onLifecycleDetached) action();
        break;
      default:
    }

    for (var action in _onLifecycleChanged) action(state);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // print('rotated');
    // This actually gets called every time the view is resized.
    // There are other ways to handle screen size changes, which may be better suited
    // than using this callback.

    for (var action in _onScreenChanged) action();
  }

  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();

    print('low memory');
    for (var action in _onLowMemory) action();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
