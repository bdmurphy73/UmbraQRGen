import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';

class QrDisplayCard extends StatelessWidget {
  final Uint8List? imageData;
  final bool isLoading;
  final String? caption;
  final VoidCallback? onTap;

  const QrDisplayCard({
    super.key,
    this.imageData,
    this.isLoading = false,
    this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.electricCyan.withOpacity(0.2)
        : AppColors.electricCyan.withOpacity(0.3);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricCyan.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.electricCyan,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (imageData != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              imageData!,
              width: 250,
              height: 280,
              fit: BoxFit.contain,
              color: Colors.white,
              colorBlendMode: BlendMode.dst,
            ),
          ),
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              caption!,
              style: const TextStyle(color: AppColors.mutedIce, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    }

    return SizedBox(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/icon_weave.svg',
            width: 48,
            height: 48,
            colorFilter: const ColorFilter.mode(
              AppColors.subtleLine,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Enter a URL to generate a QR code',
            style: TextStyle(color: AppColors.mutedIce, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
