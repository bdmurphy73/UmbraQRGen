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

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isDebouncing = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldsChanged);
    _emailController.addListener(_onFieldsChanged);
    _phoneController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() {
    if (_isDebouncing) return;
    _isDebouncing = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref
            .read(contactQrProvider.notifier)
            .generateQR(
              _nameController.text,
              _emailController.text.isNotEmpty ? _emailController.text : null,
              _phoneController.text.isNotEmpty ? _phoneController.text : null,
            );
        _isDebouncing = false;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool get _hasRequiredFields {
    return _nameController.text.isNotEmpty &&
        (_emailController.text.isNotEmpty || _phoneController.text.isNotEmpty);
  }

  Future<void> _handleSave() async {
    final success = await ref.read(contactQrProvider.notifier).saveQR();
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
    final state = ref.read(contactQrProvider);
    if (state.imageData == null) return;

    final path = await FileHelper.saveToTemp(state.imageData!);
    if (path == null) return;

    final name = _nameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;

    final body =
        '${AppStrings.shareBodyContactName}$name\n'
        '${phone.isNotEmpty ? '${AppStrings.shareBodyContactPhone}$phone\n' : ''}'
        '${email.isNotEmpty ? '${AppStrings.shareBodyContactEmail}$email\n' : ''}'
        '${AppStrings.shareBodyContactNote}';

    await Share.shareXFiles(
      [XFile(path)],
      subject: AppStrings.shareSubjectContact,
      text: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactQrProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<QrCodeState>(contactQrProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.errorRed,
          ),
        );
        ref.read(contactQrProvider.notifier).clearError();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact picker coming soon')),
              );
            },
            icon: const Icon(Icons.contact_page, color: AppColors.deepTeal),
            label: const Text(AppStrings.labelImportContacts),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepTeal,
              side: const BorderSide(color: AppColors.deepTeal),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(
              color: isDark ? AppColors.iceBlue : AppColors.lightText,
            ),
            decoration: const InputDecoration(
              labelText: AppStrings.labelContactName,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: isDark ? AppColors.iceBlue : AppColors.lightText,
            ),
            decoration: const InputDecoration(
              labelText: AppStrings.labelContactEmail,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              color: isDark ? AppColors.iceBlue : AppColors.lightText,
            ),
            decoration: const InputDecoration(
              labelText: AppStrings.labelContactPhone,
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
