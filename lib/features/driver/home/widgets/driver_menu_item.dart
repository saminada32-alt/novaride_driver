import 'package:flutter/material.dart';

class DriverMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;

  const DriverMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: titleColor ?? Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
