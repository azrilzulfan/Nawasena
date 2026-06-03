import 'package:flutter/material.dart';
import 'package:nawasena_mobile/core/theme/app_colors.dart';
import 'package:nawasena_mobile/core/theme/app_text_styles.dart';

class NawasenaLogo extends StatelessWidget {
  final double size;
  final bool showTagline;

  const NawasenaLogo({super.key, this.size = 120, this.showTagline = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mengganti container teks "N" lama dengan komponen Gambar Aset kustom
        Image.asset(
          'assets/images/Logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 14),
        Text(
          'Nawasena',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Ekosistem Panti Asuhan Digital',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ],
    );
  }
}