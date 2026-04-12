import 'dart:typed_data';

enum QrType { website, wifi, contact }

class QrCodeState {
  final Uint8List? imageData;
  final bool isLoading;
  final String? errorMessage;
  final QrType type;
  final String caption;

  const QrCodeState({
    this.imageData,
    this.isLoading = false,
    this.errorMessage,
    required this.type,
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
      type: type,
      caption: caption ?? this.caption,
    );
  }
}

class SavedImage {
  final String id;
  final String fileName;
  final String filePath;
  final QrType type;
  final String caption;
  final DateTime createdAt;

  const SavedImage({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.caption,
    required this.createdAt,
  });
}

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
