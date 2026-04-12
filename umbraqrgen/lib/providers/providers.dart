import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/qr_generator.dart';
import '../core/utils/file_helper.dart';

class QrCodeState {
  final Uint8List? imageData;
  final bool isLoading;
  final String? errorMessage;
  final String caption;

  const QrCodeState({
    this.imageData,
    this.isLoading = false,
    this.errorMessage,
    this.caption = '',
  });

  bool get hasImage => imageData != null;

  QrCodeState copyWith({
    Uint8List? imageData,
    bool? isLoading,
    String? errorMessage,
    String? caption,
  }) {
    return QrCodeState(
      imageData: imageData ?? this.imageData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      caption: caption ?? this.caption,
    );
  }
}

class WebsiteQrNotifier extends Notifier<QrCodeState> {
  @override
  QrCodeState build() => const QrCodeState();

  Future<void> generateQR(String url) async {
    if (url.isEmpty) {
      state = const QrCodeState();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final imageData = await QrGenerator.generateWebsiteQR(url);
      if (imageData != null) {
        state = QrCodeState(
          imageData: imageData,
          isLoading: false,
          caption: url,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to generate QR code',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate QR code',
      );
    }
  }

  Future<bool> saveQR() async {
    if (state.imageData == null) return false;
    final result = await FileHelper.saveToGallery(
      state.imageData!,
      QrType.website,
      state.caption,
    );
    return result != null;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final websiteQrProvider = NotifierProvider<WebsiteQrNotifier, QrCodeState>(
  WebsiteQrNotifier.new,
);

class WifiQrNotifier extends Notifier<QrCodeState> {
  @override
  QrCodeState build() => const QrCodeState();

  Future<void> generateQR(String ssid, String password) async {
    if (ssid.isEmpty || password.isEmpty) {
      state = const QrCodeState();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final imageData = await QrGenerator.generateWifiQR(ssid, password);
      if (imageData != null) {
        state = QrCodeState(
          imageData: imageData,
          isLoading: false,
          caption: 'WiFi: $ssid',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to generate QR code',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate QR code',
      );
    }
  }

  Future<bool> saveQR() async {
    if (state.imageData == null) return false;
    final result = await FileHelper.saveToGallery(
      state.imageData!,
      QrType.wifi,
      state.caption,
    );
    return result != null;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final wifiQrProvider = NotifierProvider<WifiQrNotifier, QrCodeState>(
  WifiQrNotifier.new,
);

class ContactQrNotifier extends Notifier<QrCodeState> {
  @override
  QrCodeState build() => const QrCodeState();

  Future<void> generateQR(String name, String? email, String? phone) async {
    if (name.isEmpty || (email == null && phone == null)) {
      state = const QrCodeState();
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final imageData = await QrGenerator.generateContactQR(
        name: name,
        email: email,
        phone: phone,
      );
      if (imageData != null) {
        state = QrCodeState(
          imageData: imageData,
          isLoading: false,
          caption: name,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to generate QR code',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate QR code',
      );
    }
  }

  Future<bool> saveQR() async {
    if (state.imageData == null) return false;
    final result = await FileHelper.saveToGallery(
      state.imageData!,
      QrType.contact,
      state.caption,
    );
    return result != null;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final contactQrProvider = NotifierProvider<ContactQrNotifier, QrCodeState>(
  ContactQrNotifier.new,
);

enum SortOrder { newestFirst, oldestFirst }

class SavedImagesState {
  final List<SavedImage> images;
  final bool isLoading;
  final SortOrder sortOrder;
  final bool hasPermission;

  const SavedImagesState({
    this.images = const [],
    this.isLoading = false,
    this.sortOrder = SortOrder.newestFirst,
    this.hasPermission = false,
  });

  List<SavedImage> get sortedImages {
    final list = List<SavedImage>.from(images);
    list.sort((a, b) {
      return sortOrder == SortOrder.newestFirst
          ? b.createdAt.compareTo(a.createdAt)
          : a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  SavedImagesState copyWith({
    List<SavedImage>? images,
    bool? isLoading,
    SortOrder? sortOrder,
    bool? hasPermission,
  }) {
    return SavedImagesState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      sortOrder: sortOrder ?? this.sortOrder,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

class SavedImagesNotifier extends Notifier<SavedImagesState> {
  @override
  SavedImagesState build() => const SavedImagesState();

  Future<void> loadImages() async {
    state = state.copyWith(isLoading: true);

    try {
      final images = await FileHelper.loadSavedImages();
      state = state.copyWith(
        images: images,
        isLoading: false,
        hasPermission: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> deleteImage(SavedImage image) async {
    final success = await FileHelper.deleteImage(image);
    if (success) {
      final newImages = state.images.where((i) => i.id != image.id).toList();
      state = state.copyWith(images: newImages);
    }
    return success;
  }

  void toggleSortOrder() {
    state = state.copyWith(
      sortOrder: state.sortOrder == SortOrder.newestFirst
          ? SortOrder.oldestFirst
          : SortOrder.newestFirst,
    );
  }
}

final savedImagesProvider =
    NotifierProvider<SavedImagesNotifier, SavedImagesState>(
      SavedImagesNotifier.new,
    );

final themeModeProvider = NotifierProvider<ThemeModeNotifier, bool>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() {
    state = !state;
  }
}
