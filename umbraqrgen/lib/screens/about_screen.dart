import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/spacing.dart';
import '../../providers/providers.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.midnightBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.qr_code,
              size: 48,
              color: AppColors.electricCyan,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.iceBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 14, color: AppColors.mutedIce),
          ),
          const SizedBox(height: AppSpacing.xl3),
          const Divider(color: AppColors.subtleLine),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'About This App',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.iceBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            AppStrings.aboutDeveloperNote,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedIce,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.subtleLine),
          const SizedBox(height: AppSpacing.lg),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Links',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.iceBlue,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLinkTile(
            context,
            icon: Icons.code,
            title: 'GitHub',
            subtitle: 'github.com/bdmurphy73/BDQRGen',
            onTap: () => _launchUrl(AppStrings.linkGitHub),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLinkTile(
            context,
            icon: Icons.coffee,
            title: 'Buy Me a Coffee',
            subtitle: 'buymeacoffee.com/bdmurph73i',
            onTap: () => _launchUrl(AppStrings.linkBuyMeCoffee),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLinkTile(
            context,
            icon: Icons.language,
            title: 'Website',
            subtitle: 'authorbdmurphy.com',
            onTap: () => _launchUrl(AppStrings.linkPersonalSite),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.subtleLine),
          const SizedBox(height: AppSpacing.lg),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Privacy & Legal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.iceBlue,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildLinkTile(
            context,
            icon: Icons.privacy_tip,
            title: AppStrings.aboutPrivacyPolicy,
            subtitle: 'How we handle your data',
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLinkTile(
            context,
            icon: Icons.warning,
            title: AppStrings.aboutDisclaimer,
            subtitle: 'Disclaimer of Warranty',
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLinkTile(
            context,
            icon: Icons.gavel,
            title: AppStrings.aboutLiability,
            subtitle: 'Limitation of Liability',
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildLinkTile(
            context,
            icon: Icons.description,
            title: AppStrings.aboutTermsLink,
            subtitle: 'Full Terms of Service',
            onTap: () => _launchUrl(AppStrings.linkTerms),
          ),
          const SizedBox(height: AppSpacing.xl3),
          const Divider(color: AppColors.subtleLine),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            AppStrings.aboutFooter,
            style: TextStyle(fontSize: 14, color: AppColors.mutedIce),
          ),
          GestureDetector(
            onTap: () => _launchUrl(AppStrings.linkUmbraTools),
            child: const Text(
              AppStrings.aboutWebsite,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.electricCyan,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Theme: ',
                style: TextStyle(color: AppColors.mutedIce),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(themeModeProvider.notifier).toggle();
                },
                child: Text(
                  isDark ? 'Dark' : 'Light',
                  style: const TextStyle(
                    color: AppColors.electricCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                ' (tap to toggle)',
                style: TextStyle(color: AppColors.mutedIce, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl4),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.subtleLine),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.electricCyan, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.iceBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.mutedIce,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.mutedIce),
          ],
        ),
      ),
    );
  }
}
