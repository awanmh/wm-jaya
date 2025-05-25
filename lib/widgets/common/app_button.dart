// lib/common/app_button.dart
import 'package:flutter/material.dart';

enum ButtonType { elevated, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool disabled;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.type = ButtonType.elevated,
    this.isLoading = false,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
    this.backgroundColor,
    this.textColor,
  }) : assert(
         !(isLoading && onPressed != null),
         'Cannot have both loading and onPressed',
       );

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || isLoading;
    final buttonStyle = Theme.of(context).extension<ButtonStyles>();

    Widget button;
    switch (type) {
      case ButtonType.elevated:
        button = ElevatedButton(
          style: _mergeStyles(buttonStyle?.elevated, isDisabled),
          onPressed: isDisabled ? null : onPressed,
          child: _buildContent(),
        );
      case ButtonType.outlined:
        button = OutlinedButton(
          style: _mergeStyles(buttonStyle?.outlined, isDisabled),
          onPressed: isDisabled ? null : onPressed,
          child: _buildContent(),
        );
      case ButtonType.text:
        button = TextButton(
          style: _mergeStyles(buttonStyle?.text, isDisabled),
          onPressed: isDisabled ? null : onPressed,
          child: _buildContent(),
        );
    }

    return SizedBox(
      width: width,
      child: Padding(
        padding: padding,
        child: button,
      ),
    );
  }

  ButtonStyle _mergeStyles(ButtonStyle? themeStyle, bool isDisabled) {
    return (themeStyle ?? const ButtonStyle()).merge(
      ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (isDisabled) return Colors.grey[300];
            return backgroundColor;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (isDisabled) return Colors.grey[600];
            return textColor;
          },
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (isDisabled) return null;
            if (states.contains(WidgetState.pressed)) {
              return const Color(0x1A0000FF);
            }
            if (states.contains(WidgetState.hovered)) {
              return const Color(0x0D0000FF);
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(2.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : Text(
              text,
              key: const ValueKey('button-text'),
              style: TextStyle(
                color: textColor,
              ),
            ),
    );
  }
}

@immutable
class ButtonStyles extends ThemeExtension<ButtonStyles> {
  final ButtonStyle? elevated;
  final ButtonStyle? outlined;
  final ButtonStyle? text;

  const ButtonStyles({
    required this.elevated,
    required this.outlined,
    required this.text,
  });

  @override
  ThemeExtension<ButtonStyles> copyWith({
    ButtonStyle? elevated,
    ButtonStyle? outlined,
    ButtonStyle? text,
  }) {
    return ButtonStyles(
      elevated: elevated ?? this.elevated,
      outlined: outlined ?? this.outlined,
      text: text ?? this.text,
    );
  }

  @override
  ThemeExtension<ButtonStyles> lerp(
    ThemeExtension<ButtonStyles>? other,
    double t,
  ) {
    if (other is! ButtonStyles) return this;
    return ButtonStyles(
      elevated: ButtonStyle.lerp(elevated, other.elevated, t),
      outlined: ButtonStyle.lerp(outlined, other.outlined, t),
      text: ButtonStyle.lerp(text, other.text, t),
    );
  }
}