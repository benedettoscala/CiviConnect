import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A custom widget that displays the application's logo.
class LogoWidget extends StatelessWidget {
  /// Creates a custom logo widget.
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    String logoPath = kIsWeb || !Platform.isAndroid
        ? 'images/logo_blu.svg'
        : 'assets/images/logo_blu.svg';

    return ClipRRect(
      borderRadius: BorderRadius.circular(125.0),
      child: SvgPicture.asset(
        logoPath,
        fit: BoxFit.none,
        height: 250,
        width: 250,
        semanticsLabel: 'Logo CiviConnect',
        placeholderBuilder: (context) =>
            const CircularProgressIndicator(backgroundColor: Colors.blue),
      ),
    );
  }
}
