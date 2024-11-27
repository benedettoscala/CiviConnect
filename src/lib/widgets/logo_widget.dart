import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A custom widget that displays the application's logo.
/// This widget is designed to show the logo of the application.
/// The logo is displayed as an SVG image.
/// The widget is customizable optional with a `borderRadius` parameter.
class LogoWidget extends StatelessWidget {

  /// The border radius of the logo widget
  /// Default value is 0.0
  /// If set, the logo will be clipped with the circular specified border radius.
  final double borderRadius;

  /// Creates a custom logo widget.
  const LogoWidget({super.key, this.borderRadius = 10.0});

  @override
  Widget build(BuildContext context) {
    String logoPath = kIsWeb || !Platform.isAndroid
        ? 'images/logo_blu-cropped.svg'
        : 'assets/images/logo_blu-cropped.svg';

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: SvgPicture.asset(
        logoPath,
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height * 0.2,
        //width: 200,
        semanticsLabel: 'Logo CiviConnect',
        placeholderBuilder: (context) =>
            const CircularProgressIndicator(backgroundColor: Colors.blue),
      ),
    );
  }
}