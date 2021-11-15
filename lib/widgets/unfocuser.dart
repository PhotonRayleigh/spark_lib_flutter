import 'package:flutter/widgets.dart';

/// A simple implementation of a widget that lets the user unfocus
/// input elements by tapping on the background.
/// For a complex and more feature rich implementation, use
/// Unfocuser from https://github.com/caseyryan/flutter_multi_formatter
class Unfocuser extends StatelessWidget {
  final FocusNode _bgNode = FocusNode();
  final Widget child;

  Unfocuser({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: _bgNode,
        child: GestureDetector(
          child: child,
          onTap: () {
            if (_bgNode.hasFocus) {
              _bgNode.unfocus();
            } else {
              _bgNode.requestFocus();
            }
          },
        ));
  }
}
