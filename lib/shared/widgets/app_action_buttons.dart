import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final TextStyle? textStyle;
  final double? width;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.textStyle,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.primary,
          padding: padding,
          elevation: elevation,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? height;
  final BorderRadius borderRadius;
  final Color? foregroundColor;
  final BorderSide? side;
  final double iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double? width;

  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 56,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.foregroundColor,
    this.side,
    this.iconSize = 24,
    this.iconColor,
    this.textStyle,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      side:
          side ??
          BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    );

    return SizedBox(
      width: width,
      height: height,
      child: icon == null
          ? OutlinedButton(
              onPressed: onPressed,
              style: style,
              child: Text(label, style: textStyle),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon, size: iconSize, color: iconColor),
              label: Text(label, style: textStyle),
            ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.foregroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        textStyle: textStyle,
      ),
      child: Text(label, style: textStyle),
    );
  }
}

class AppDestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  const AppDestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
        backgroundColor: filled ? Colors.red.shade50 : null,
        padding: filled ? const EdgeInsets.symmetric(vertical: 14) : null,
        shape: filled
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            : null,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
