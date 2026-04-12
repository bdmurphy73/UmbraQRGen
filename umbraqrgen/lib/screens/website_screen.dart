import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/spacing.dart';
import '../../core/utils/file_helper.dart';
import '../../providers/providers.dart';
import '../../widgets/qr_display_card.dart';
import '../../widgets/action_button_row.dart';

class WebsiteScreen extends ConsumerStatefulWidget {
  const WebsiteScreen({super.key});

  @override
  ConsumerState<WebsiteScreen> createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends ConsumerState<WebsiteScreen> {
  final _urlController = TextEditingController(
    text: AppStrings.defaultWebsiteUrl,
  );
  bool _isDebouncing = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    if (_isDebouncing) return;
    _isDebouncing = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(websiteQrProvider.notifier).generateQR(_urlController.text);
        _isDebouncing = false;
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final success = await ref.read(websiteQrProvider.notifier).saveQR();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? AppStrings.msgSaveSuccess : AppStrings.msgSaveFailed,
          ),
          backgroundColor: success
              ? AppColors.successGreen
              : AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _handleShare() async {
    final state = ref.read(websiteQrProvider);
    if (state.imageData == null) return;

    final path = await FileHelper.saveToTemp(state.imageData!);
    if (path == null) return;

    final body = '${AppStrings.shareBodyWebsite}${state.caption}';
    await Share.shareXFiles(
      [XFile(path)],
      subject: AppStrings.shareSubjectWebsite,
      text: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(websiteQrProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<QrCodeState>(websiteQrProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.errorRed,
          ),
        );
        ref.read(websiteQrProvider.notifier).clearError();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            style: TextStyle(
              color: isDark ? AppColors.iceBlue : AppColors.lightText,
            ),
            decoration: const InputDecoration(
              labelText: AppStrings.labelWebsiteUrl,
              hintText: AppStrings.hintWebsiteUrl,
            ),
          ),
          const SizedBox(height: AppSpacing.xl2),
          QrDisplayCard(
            imageData: state.imageData,
            isLoading: state.isLoading,
            caption: state.caption,
          ),
          const SizedBox(height: AppSpacing.xl),
          ActionButtonRow(
            onSave: _handleSave,
            onShare: _handleShare,
            enabled: state.hasImage,
          ),
        ],
      ),
    );
  }
}
