import 'package:flutter/material.dart';
import 'package:stutz/core/theme/app_theme.dart';

class GradientPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<GradientPrimaryButton> createState() => _GradientPrimaryButtonState();
}

class _GradientPrimaryButtonState extends State<GradientPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        // Subtiler Opacity-Fade für Tap-States
        opacity: _isPressed ? 0.8 : 1.0,
        child: Container(
          width: double.infinity, // Full width button
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0), // rounded-md
            gradient: const LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.primaryContainer,
              ], // #006565 zu #008080
              begin: Alignment.topLeft,
              end: Alignment.bottomRight, // ~135 Grad
            ),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white, // on-primary
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
