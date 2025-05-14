import 'package:flutter/material.dart';

class TerminalMenuButton extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final VoidCallback onTap;
  final IconData? icon;

  const TerminalMenuButton({
    Key? key,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            iconColor: textColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: textColor),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
