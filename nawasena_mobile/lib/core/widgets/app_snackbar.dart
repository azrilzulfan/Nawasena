import 'package:flutter/material.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';

enum SnackBarType { success, error, info, warning }

class AppSnackBar {
  AppSnackBar._();

  static void show(
      BuildContext context, {
        required String message,
        SnackBarType type = SnackBarType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    final config = _getConfig(type);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(config.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: config.color,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  static ({Color color, IconData icon}) _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return (color: AppColors.success, icon: Icons.check_circle_outline_rounded);
      case SnackBarType.error:
        return (color: AppColors.error, icon: Icons.error_outline_rounded);
      case SnackBarType.warning:
        return (color: AppColors.warning, icon: Icons.warning_amber_rounded);
      case SnackBarType.info:
        return (color: AppColors.info, icon: Icons.info_outline_rounded);
    }
  }
}