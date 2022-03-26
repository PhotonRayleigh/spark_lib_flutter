import 'package:flutter/widgets.dart';

class WindowData {
  WindowData({
    this.initialSize = const Size(900, 600),
    this.minimumSize = const Size(200, 200),
    this.windowAlignment = Alignment.center,
    this.windowTitle = "Flutter App",
  });

  Size initialSize;
  Size minimumSize;
  Alignment windowAlignment;
  String windowTitle;
}
