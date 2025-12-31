import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../data/models/category_model.dart';
import '../providers/auction_creation_provider.dart';

class AuctionFormStep2 extends ConsumerStatefulWidget {
  const AuctionFormStep2({super.key});

  @override
  ConsumerState<AuctionFormStep2> createState() => _AuctionFormStep2State();
}

class _AuctionFormStep2State extends ConsumerState<AuctionFormStep2> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final creationState = ref.watch(auctionCreationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Images & Category',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Add photos and select a category for your item',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Category Selection
          _buildCategorySection(theme, creationState),
          
          const SizedBox(height: 24),
          
          // Image Upload Section
          _buildImageSection(theme, creationState),
          
          const SizedBox(height: 24),
          
          // Image Guidelines
          _buildImageGuidelines(theme),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme, AuctionCreationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        if (state.categories.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else
          DropdownButtonFormField<CategoryModel>(
            initialValue: state.selectedCategory,
            decoration: InputDecoration(
              labelText: 'Select Category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: state.categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (category) {
              if (category != null) {
                ref.read(auctionCreationProvider.notifier).selectCategory(category);
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildImageSection(ThemeData theme, AuctionCreationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos (${state.totalImages}/12)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (state.totalImages < 12)
              CustomButton(
                text: 'Add Photos',
                onPressed: _showImageSourceDialog,
                variant: ButtonVariant.outlined,
                icon: Icons.add_photo_alternate,
              ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        if (state.totalImages == 0)
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add Photos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add photos from camera or gallery',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          _buildImageGrid(theme, state),
        
        if (state.isUploading) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: state.uploadProgress),
          const SizedBox(height: 8),
          Text(
            'Uploading images...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageGrid(ThemeData theme, AuctionCreationState state) {
    final allImages = <Widget>[];
    
    // Add selected images (not yet uploaded)
    for (int i = 0; i < state.selectedImages.length; i++) {
      allImages.add(_buildImageTile(
        theme,
        imageFile: state.selectedImages[i],
        index: i,
        onRemove: () => ref.read(auctionCreationProvider.notifier).removeImage(i),
      ));
    }
    
    // Add uploaded images
    for (int i = 0; i < state.uploadedImageUrls.length; i++) {
      final globalIndex = state.selectedImages.length + i;
      allImages.add(_buildImageTile(
        theme,
        imageUrl: state.uploadedImageUrls[i],
        index: globalIndex,
        onRemove: () => ref.read(auctionCreationProvider.notifier).removeImage(globalIndex),
      ));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: allImages,
    );
  }

  Widget _buildImageTile(
    ThemeData theme, {
    File? imageFile,
    String? imageUrl,
    required int index,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageFile != null
                ? Image.file(
                    imageFile,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.errorContainer,
                            child: Icon(
                              Icons.broken_image,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
          ),
        ),
        
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        
        // Index indicator
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Main',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageGuidelines(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Photo Guidelines',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '• First photo will be the main image\n'
            '• Use good lighting and clear focus\n'
            '• Show different angles of the item\n'
            '• Include close-ups of important details\n'
            '• Maximum 12 photos allowed\n'
            '• Supported formats: JPG, PNG',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Multiple Photos'),
                onTap: () {
                  Navigator.pop(context);
                  _pickMultipleImages();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        ref.read(auctionCreationProvider.notifier).addImages([File(image.path)]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty) {
        final files = images.map((image) => File(image.path)).toList();
        ref.read(auctionCreationProvider.notifier).addImages(files);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
