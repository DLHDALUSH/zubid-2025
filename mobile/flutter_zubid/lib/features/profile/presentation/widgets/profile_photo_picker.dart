import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoPicker extends StatelessWidget {
  final String? currentPhotoUrl;
  final File? selectedImage;
  final Function(File) onImageSelected;
  final VoidCallback onImageRemoved;
  final bool isUploading;

  const ProfilePhotoPicker({
    super.key,
    this.currentPhotoUrl,
    this.selectedImage,
    required this.onImageSelected,
    required this.onImageRemoved,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          // Profile Photo
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _buildPhotoWidget(context),
                ),
              ),
              
              // Loading Overlay
              if (isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              
              // Edit Button
              if (!isUploading)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      onPressed: () => _showPhotoOptions(context),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Photo Actions
          if (!isUploading) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () => _showPhotoOptions(context),
                  icon: const Icon(Icons.photo_camera),
                  label: Text(
                    selectedImage != null || currentPhotoUrl != null
                        ? 'Change Photo'
                        : 'Add Photo',
                  ),
                ),
                
                if (selectedImage != null || currentPhotoUrl != null) ...[
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: onImageRemoved,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ] else ...[
            Text(
              'Uploading photo...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        fit: BoxFit.cover,
      );
    } else if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: currentPhotoUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultAvatar(context),
      );
    } else {
      return _buildDefaultAvatar(context);
    }
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    } catch (e) {
      // Handle error - could show a snackbar or dialog
      debugPrint('Error picking image: $e');
    }
  }
}
