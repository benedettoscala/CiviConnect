import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
/// A custom class to create the input decoration for the text form fields.
/// This class extends the InputDecoration class and provides a custom input decoration.
///
/// [labelText] is a required parameter, a string that represents the label text of the text form field.
///
/// [onObscure] is an optional parameter, a callback that is called when the eye-icon is pressed.
/// If null, the eye-icon is not displayed.
///
/// [obscureText] is an optional parameter, a boolean that determines if the text is obscured.
/// Pass this parameter as true if the text is obscured.
/// Pass a variable to set the State in the caller widget to change the obscureText value.
class TextFieldInputDecoration extends InputDecoration {
  /// A callback that is called when the eye-icon is pressed.
  final VoidCallback? onObscure;

  /// A boolean that determines if the text is obscured.
  final bool obscureText;

  /// Creates a custom input decoration for the text form fields.
  /// The input decoration is filled with the color scheme of the current theme onPrimary.
  /// The label text is set to the provided labelText.
  /// onObscure is a callback that is called when the eye-icon is pressed.
  /// If null, the eye-icon is not displayed.
  /// The eye-icon changes based on the obscureText parameter.
  TextFieldInputDecoration(BuildContext context,
      {this.onObscure, this.obscureText = false,
        super.icon,
        super.iconColor,
        super.label,
        super.labelText,
        super.floatingLabelStyle,
        super.helper,
        super.helperText,
        super.helperStyle,
        super.helperMaxLines,
        super.hintText,
        super.hintStyle,
        super.hintTextDirection,
        super.hintMaxLines,
        super.hintFadeDuration,
        super.error,
        super.errorText,
        super.floatingLabelAlignment,
        super.isCollapsed,
        //super.isDense,
        super.prefixIcon,
        super.prefixIconConstraints,
        super.prefix,
        super.prefixText,
        super.prefixStyle,
        super.prefixIconColor,
        super.suffix,
        super.suffixText,
        super.suffixStyle,
        super.suffixIconColor,
        super.suffixIconConstraints,
        super.counter,
        super.counterText,
        super.focusColor,
        super.hoverColor,
        super.focusedBorder,
        super.focusedErrorBorder,
        super.disabledBorder,
        super.enabledBorder,
        super.enabled = true,
        super.semanticCounterText,
        super.alignLabelWithHint,
        super.constraints,
      })
      : super(
    isDense: true,
    contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
    filled: true,
    fillColor: Theme
        .of(context)
        .colorScheme
        .onPrimary,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    labelStyle: TextStyle(
      color: Theme
          .of(context)
          .colorScheme
          .onPrimaryContainer,
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .onPrimary,
    ),
    border: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
    errorBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        width: 3,
        color: Theme
            .of(context)
            .colorScheme
            .error,
      ),
    ),
    errorMaxLines: 2,
    errorStyle: TextStyle(
      color: Theme
          .of(context)
          .colorScheme
          .onPrimary,
    ),
    counterStyle: TextStyle(
      color: Theme
          .of(context)
          .colorScheme
          .onPrimaryContainer,
    ),
    suffixIcon: (onObscure == null)
        ? null
        : Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: IconButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
              Theme
                  .of(context)
                  .shadowColor
                  .withAlpha(20)),
          animationDuration: const Duration(milliseconds: 200),
          elevation: WidgetStatePropertyAll(2),
        ),
        tooltip: 'Mostra/Nascondi password',
        icon: obscureText
            ? HugeIcon(
          icon: HugeIcons.strokeRoundedViewOff,
          color: Theme
              .of(context)
              .colorScheme
              .onPrimaryContainer,
        )
            : HugeIcon(
            icon: HugeIcons.strokeRoundedView,
            color: Theme
                .of(context)
                .colorScheme
                .onPrimaryContainer),
        color: Theme
            .of(context)
            .colorScheme
            .onPrimary,
        onPressed: () {
          onObscure.call();
        },
      ),
    ),
  );



}