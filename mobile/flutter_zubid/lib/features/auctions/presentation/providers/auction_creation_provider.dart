import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/auction_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/create_auction_model.dart';
import '../../data/repositories/auction_creation_repository.dart';

class AuctionCreationState {
  final bool isLoading;
  final String? error;
  final List<File> selectedImages;
  final List<String> uploadedImageUrls;
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final CreateAuctionRequest? draftAuction;
  final bool isUploading;
  final double uploadProgress;

  const AuctionCreationState({
    this.isLoading = false,
    this.error,
    this.selectedImages = const [],
    this.uploadedImageUrls = const [],
    this.categories = const [],
    this.selectedCategory,
    this.draftAuction,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  AuctionCreationState copyWith({
    bool? isLoading,
    String? error,
    List<File>? selectedImages,
    List<String>? uploadedImageUrls,
    List<CategoryModel>? categories,
    CategoryModel? selectedCategory,
    CreateAuctionRequest? draftAuction,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return AuctionCreationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedImages: selectedImages ?? this.selectedImages,
      uploadedImageUrls: uploadedImageUrls ?? this.uploadedImageUrls,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      draftAuction: draftAuction ?? this.draftAuction,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  bool get hasError => error != null;
  bool get hasImages => selectedImages.isNotEmpty || uploadedImageUrls.isNotEmpty;
  bool get canCreateAuction => draftAuction?.isValid == true && hasImages;
  int get totalImages => selectedImages.length + uploadedImageUrls.length;
}

class AuctionCreationNotifier extends StateNotifier<AuctionCreationState> {
  final AuctionCreationRepository _repository;

  AuctionCreationNotifier(this._repository) : super(const AuctionCreationState()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getCategories();
    
    result.when(
      success: (categories) {
        state = state.copyWith(
          isLoading: false,
          categories: categories,
        );
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Failed to load categories: $error');
      },
    );
  }

  void selectCategory(CategoryModel category) {
    state = state.copyWith(selectedCategory: category);
    AppLogger.info('Category selected: ${category.name}');
  }

  void addImages(List<File> images) {
    final newImages = [...state.selectedImages, ...images];
    if (newImages.length > 12) {
      state = state.copyWith(error: 'Maximum 12 images allowed');
      return;
    }
    
    state = state.copyWith(
      selectedImages: newImages,
      error: null,
    );
    AppLogger.info('Added ${images.length} images, total: ${newImages.length}');
  }

  void removeImage(int index) {
    if (index < state.selectedImages.length) {
      final newImages = [...state.selectedImages];
      newImages.removeAt(index);
      state = state.copyWith(selectedImages: newImages);
    } else {
      final urlIndex = index - state.selectedImages.length;
      if (urlIndex < state.uploadedImageUrls.length) {
        final newUrls = [...state.uploadedImageUrls];
        newUrls.removeAt(urlIndex);
        state = state.copyWith(uploadedImageUrls: newUrls);
      }
    }
    AppLogger.info('Removed image at index: $index');
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex < state.selectedImages.length && newIndex < state.selectedImages.length) {
      final newImages = [...state.selectedImages];
      final item = newImages.removeAt(oldIndex);
      newImages.insert(newIndex, item);
      state = state.copyWith(selectedImages: newImages);
    }
    AppLogger.info('Reordered images: $oldIndex -> $newIndex');
  }

  Future<bool> uploadImages() async {
    if (state.selectedImages.isEmpty) return true;

    state = state.copyWith(isUploading: true, uploadProgress: 0.0, error: null);

    final result = await _repository.uploadImages(state.selectedImages);
    
    return result.when(
      success: (imageUrls) {
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 1.0,
          uploadedImageUrls: [...state.uploadedImageUrls, ...imageUrls],
          selectedImages: [], // Clear selected images after upload
        );
        AppLogger.info('Images uploaded successfully: ${imageUrls.length}');
        return true;
      },
      error: (error) {
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 0.0,
          error: error,
        );
        AppLogger.error('Image upload failed: $error');
        return false;
      },
    );
  }

  void saveDraft(CreateAuctionRequest request) {
    state = state.copyWith(draftAuction: request);
    AppLogger.info('Draft auction saved: ${request.title}');
  }

  void clearDraft() {
    state = state.copyWith(draftAuction: null);
    AppLogger.info('Draft auction cleared');
  }

  Future<bool> createAuction(CreateAuctionRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    // Upload images first if needed
    if (state.selectedImages.isNotEmpty) {
      final uploadSuccess = await uploadImages();
      if (!uploadSuccess) {
        state = state.copyWith(isLoading: false);
        return false;
      }
    }

    // Create auction with uploaded image URLs
    final finalRequest = CreateAuctionRequest(
      title: request.title,
      description: request.description,
      categoryId: request.categoryId,
      startingBid: request.startingBid,
      buyNowPrice: request.buyNowPrice,
      endTime: request.endTime,
      imageUrls: state.uploadedImageUrls,
      condition: request.condition,
      brand: request.brand,
      model: request.model,
      specifications: request.specifications,
      shippingInfo: request.shippingInfo,
      allowInternationalShipping: request.allowInternationalShipping,
      returnPolicy: request.returnPolicy,
      handlingTime: request.handlingTime,
      autoRelist: request.autoRelist,
      relistCount: request.relistCount,
    );

    final result = await _repository.createAuction(finalRequest);
    
    return result.when(
      success: (response) {
        state = state.copyWith(isLoading: false);
        // Clear form after successful creation
        _resetForm();
        AppLogger.info('Auction created successfully: ${response.auctionId}');
        return true;
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Auction creation failed: $error');
        return false;
      },
    );
  }

  void _resetForm() {
    state = const AuctionCreationState();
    _loadCategories();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final auctionCreationProvider = StateNotifierProvider<AuctionCreationNotifier, AuctionCreationState>((ref) {
  final repository = ref.read(auctionCreationRepositoryProvider);
  return AuctionCreationNotifier(repository);
});

final categoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(auctionCreationProvider).categories;
});

final selectedCategoryProvider = Provider<CategoryModel?>((ref) {
  return ref.watch(auctionCreationProvider).selectedCategory;
});
