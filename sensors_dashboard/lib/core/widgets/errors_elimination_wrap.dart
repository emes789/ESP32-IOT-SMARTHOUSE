import 'package:flutter/material.dart';
class ErrorsEliminationWrap extends StatelessWidget {
  final Widget child;
  const ErrorsEliminationWrap({
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Banner(
      location: BannerLocation.topStart,
      message: '',
      color: Colors.transparent,
      child: child,
    );
  }
}
