import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';

class ActionButtonRow extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final bool enabled;

  const ActionButtonRow({
    super.key,
    this.onSave,
    this.onShare,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.electricCyan : AppColors.lightCyan;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: enabled ? onSave : null,
            icon: SvgPicture.asset(
              'assets/icons/icon_save.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                enabled ? AppColors.midnightBlue : AppColors.mutedIce,
                BlendMode.srcIn,
              ),
            ),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? primaryColor : AppColors.subtleLine,
              foregroundColor: enabled
                  ? AppColors.midnightBlue
                  : AppColors.mutedIce,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: enabled ? onShare : null,
            icon: SvgPicture.asset(
              'assets/icons/icon_share.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                enabled ? primaryColor : AppColors.mutedIce,
                BlendMode.srcIn,
              ),
            ),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: enabled ? primaryColor : AppColors.mutedIce,
              side: BorderSide(
                color: enabled ? primaryColor : AppColors.subtleLine,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
