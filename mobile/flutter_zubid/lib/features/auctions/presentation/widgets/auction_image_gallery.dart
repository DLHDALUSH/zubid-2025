import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/smart_image.dart';

class AuctionImageGallery extends StatefulWidget {
  final List<String> images;
  final String? heroTag;

  const AuctionImageGallery({
    super.key,
    required this.images,
    this.heroTag,
  });

  @override
  State<AuctionImageGallery> createState() => _AuctionImageGalleryState();
}

class _AuctionImageGalleryState extends State<AuctionImageGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      children: [
        // Main Image Gallery
        GestureDetector(
          onTap: () => _showFullScreenGallery(context),
          child: Hero(
            tag: widget.heroTag ?? 'auction-gallery',
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return _buildImage(widget.images[index]);
              },
            ),
          ),
        ),

        // Image Counter
        if (widget.images.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Navigation Arrows
        if (widget.images.length > 1) ...[
          // Previous Button
          if (_currentIndex > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),

          // Next Button
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],

        // Thumbnail Strip
        if (widget.images.length > 1)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildThumbnailStrip(),
          ),
      ],
    );
  }

  Widget _buildImage(String imageUrl) {
    return SmartImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorWidget: _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'No Image Available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailStrip() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;

          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
              child: SmartImage(
                imageUrl: widget.images[index],
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(6),
                errorWidget: Container(
                  color: Colors.grey.withValues(alpha: 0.3),
                  child: const Icon(Icons.image_outlined, size: 24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenGallery(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageGallery(
          images: widget.images,
          initialIndex: _currentIndex,
          heroTag: widget.heroTag,
        ),
      ),
    );
  }
}

class FullScreenImageGallery extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  final String? heroTag;

  const FullScreenImageGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Hero(
        tag: heroTag ?? 'auction-gallery',
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            final imageUrl = AppConfig.getFullImageUrl(images[index]);
            return PhotoViewGalleryPageOptions(
              imageProvider: _getImageProvider(imageUrl),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          itemCount: images.length,
          loadingBuilder: (context, event) => Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded /
                        (event.expectedTotalBytes ?? 1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          pageController: PageController(initialPage: initialIndex),
        ),
      ),
    );
  }

  /// Get the appropriate ImageProvider based on the image URL type
  ImageProvider _getImageProvider(String imageUrl) {
    if (AppConfig.isDataUri(imageUrl)) {
      // For data URIs, decode and use MemoryImage
      try {
        final parts = imageUrl.split(',');
        if (parts.length == 2) {
          final Uint8List bytes = base64Decode(parts[1]);
          return MemoryImage(bytes);
        }
      } catch (e) {
        // Fall back to network image provider if decoding fails
      }
    }
    // For regular URLs, use CachedNetworkImageProvider
    return CachedNetworkImageProvider(imageUrl);
  }
}
