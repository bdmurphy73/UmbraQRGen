import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/constants/spacing.dart';
import '../../core/utils/file_helper.dart';
import '../../providers/providers.dart';

class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedImagesProvider.notifier).loadImages();
    });
  }

  void _showDeleteDialog(SavedImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.titleDeleteConfirm),
        content: const Text(AppStrings.messageDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.actionCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(savedImagesProvider.notifier).deleteImage(image);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.msgDeleteSuccess),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              }
            },
            child: Text(
              AppStrings.actionDelete,
              style: const TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageViewer(SavedImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.mutedIce),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              if (File(image.filePath).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(image.filePath),
                    width: 250,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                image.fileName.replaceAll('.png', ''),
                style: const TextStyle(color: AppColors.iceBlue, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final path = await FileHelper.saveToTemp(
                          await File(image.filePath).readAsBytes(),
                        );
                        if (path != null) {
                          await Share.shareXFiles(
                            [XFile(path)],
                            subject: AppStrings.shareSubjectSaved,
                            text:
                                '${AppStrings.shareBodySaved}${image.caption}',
                          );
                        }
                      },
                      icon: const Icon(Icons.share),
                      label: const Text(AppStrings.actionShare),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final bytes = await File(image.filePath).readAsBytes();
                        final result = await FileHelper.saveToGallery(
                          bytes,
                          image.type,
                          image.caption,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result != null
                                    ? AppStrings.msgSaveSuccess
                                    : AppStrings.msgSaveFailed,
                              ),
                              backgroundColor: result != null
                                  ? AppColors.successGreen
                                  : AppColors.errorRed,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text(AppStrings.actionSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savedImagesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.sortedImages.length} codes',
                style: const TextStyle(color: AppColors.mutedIce, fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.sort, color: AppColors.mutedIce),
                onPressed: () {
                  ref.read(savedImagesProvider.notifier).toggleSortOrder();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.electricCyan,
                  ),
                )
              : state.sortedImages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code,
                        size: 64,
                        color: AppColors.subtleLine,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        AppStrings.emptyStateSaved,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.mutedIce,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: state.sortedImages.length,
                  itemBuilder: (context, index) {
                    final image = state.sortedImages[index];
                    return GestureDetector(
                      onTap: () => _showImageViewer(image),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.subtleLine),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: File(image.filePath).existsSync()
                                    ? Image.file(
                                        File(image.filePath),
                                        fit: BoxFit.contain,
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: AppColors.mutedIce,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      image.fileName.replaceAll('.png', ''),
                                      style: const TextStyle(
                                        color: AppColors.iceBlue,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showDeleteDialog(image),
                                    child: const Icon(
                                      Icons.delete,
                                      color: AppColors.errorRed,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
