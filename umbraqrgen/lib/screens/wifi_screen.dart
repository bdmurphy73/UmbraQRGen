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

class WifiScreen extends ConsumerStatefulWidget {
  const WifiScreen({super.key});

  @override
  ConsumerState<WifiScreen> createState() => _WifiScreenState();
}

class _WifiScreenState extends ConsumerState<WifiScreen> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isDebouncing = false;

  @override
  void initState() {
    super.initState();
    _ssidController.addListener(_onFieldsChanged);
    _passwordController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() {
    if (_isDebouncing) return;
    _isDebouncing = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref
            .read(wifiQrProvider.notifier)
            .generateQR(_ssidController.text, _passwordController.text);
        _isDebouncing = false;
      }
    });
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final success = await ref.read(wifiQrProvider.notifier).saveQR();
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
    final state = ref.read(wifiQrProvider);
    if (state.imageData == null) return;

    final path = await FileHelper.saveToTemp(state.imageData!);
    if (path == null) return;

    final ssid = _ssidController.text;
    final password = _passwordController.text;
    final body =
        '${AppStrings.shareBodyWifiNetwork}$ssid\n'
        '${AppStrings.shareBodyWifiPassword}$password'
        '${AppStrings.shareBodyWifiNote}';

    await Share.shareXFiles(
      [XFile(path)],
      subject: AppStrings.shareSubjectWifi,
      text: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wifiQrProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<QrCodeState>(wifiQrProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.errorRed,
          ),
        );
        ref.read(wifiQrProvider.notifier).clearError();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          TextField(
            controller: _ssidController,
            style: TextStyle(
              color: isDark ? AppColors.iceBlue : AppColors.lightText,
            ),
            decoration: const InputDecoration(
              labelText: AppStrings.labelWifiSsid,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(
              color: isDark ? AppColors.iceBlue : AppColors.lightText,
            ),
            decoration: InputDecoration(
              labelText: AppStrings.labelWifiPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.mutedIce,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
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
