import 'package:flutter/material.dart';
class DebugOverflowSupressor extends StatelessWidget {
  final Widget child;
  const DebugOverflowSupressor({
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Banner(
      location: BannerLocation.topStart,
      message: '',
      color: Colors.transparent,
      textStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
      child: child,
    );
  }
}
