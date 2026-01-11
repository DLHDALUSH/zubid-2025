import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';
import 'smart_image.dart';
import 'video_player_widget.dart';

/// Enhanced media gallery that supports both images and videos
class MediaGalleryWidget extends StatefulWidget {
  final List<String> mediaUrls;
  final String? heroTag;
  final double? height;
  final bool showThumbnails;
  final bool autoPlay;

  const MediaGalleryWidget({
    super.key,
    required this.mediaUrls,
    this.heroTag,
    this.height,
    this.showThumbnails = true,
    this.autoPlay = false,
  });

  @override
  State<MediaGalleryWidget> createState() => _MediaGalleryWidgetState();
}

class _MediaGalleryWidgetState extends State<MediaGalleryWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaUrls.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      children: [
        // Main Media Gallery
        GestureDetector(
          onTap: () => _showFullScreenGallery(context),
          child: Hero(
            tag: widget.heroTag ?? 'media-gallery',
            child: Container(
              height: widget.height,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.mediaUrls.length,
                itemBuilder: (context, index) {
                  return _buildMediaItem(widget.mediaUrls[index]);
                },
              ),
            ),
          ),
        ),

        // Media Type Indicator
        if (widget.mediaUrls.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: _buildMediaTypeIndicator(),
          ),

        // Page Indicators
        if (widget.mediaUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildPageIndicators(),
          ),

        // Thumbnail Strip
        if (widget.showThumbnails && widget.mediaUrls.length > 1)
          Positioned(
            bottom: 60,
            left: 16,
            right: 16,
            child: _buildThumbnailStrip(),
          ),
      ],
    );
  }

  Widget _buildMediaItem(String mediaUrl) {
    if (_isVideoUrl(mediaUrl)) {
      return VideoPlayerWidget(
        videoUrl: mediaUrl,
        autoPlay: widget.autoPlay,
        showControls: true,
        borderRadius: BorderRadius.circular(12),
      );
    } else {
      return SmartImage(
        imageUrl: mediaUrl,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
      );
    }
  }

  Widget _buildMediaTypeIndicator() {
    final currentMedia = widget.mediaUrls[_currentIndex];
    final isVideo = _isVideoUrl(currentMedia);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVideo ? Icons.play_circle_outline : Icons.image_outlined,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isVideo ? 'Video' : 'Image',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.mediaUrls.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentIndex
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailStrip() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.mediaUrls.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          final isVideo = _isVideoUrl(widget.mediaUrls[index]);

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
              child: Stack(
                children: [
                  SmartImage(
                    imageUrl: widget.mediaUrls[index],
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(6),
                    errorWidget: Container(
                      color: Colors.grey.withValues(alpha: 0.3),
                      child: const Icon(Icons.image_outlined, size: 24),
                    ),
                  ),
                  if (isVideo)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    final theme = Theme.of(context);
    return Container(
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No media available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v'];
    final lowerUrl = url.toLowerCase();
    return videoExtensions.any((ext) => lowerUrl.contains(ext)) ||
        lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('vimeo.com');
  }

  void _showFullScreenGallery(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenMediaGallery(
          mediaUrls: widget.mediaUrls,
          initialIndex: _currentIndex,
          heroTag: widget.heroTag,
        ),
      ),
    );
  }
}

/// Full-screen media gallery for viewing images and videos
class _FullScreenMediaGallery extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;
  final String? heroTag;

  const _FullScreenMediaGallery({
    required this.mediaUrls,
    required this.initialIndex,
    this.heroTag,
  });

  @override
  State<_FullScreenMediaGallery> createState() =>
      _FullScreenMediaGalleryState();
}

class _FullScreenMediaGalleryState extends State<_FullScreenMediaGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.mediaUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Hero(
        tag: widget.heroTag ?? 'media-gallery',
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: widget.mediaUrls.length,
          itemBuilder: (context, index) {
            final mediaUrl = widget.mediaUrls[index];

            if (_isVideoUrl(mediaUrl)) {
              return Center(
                child: VideoPlayerWidget(
                  videoUrl: mediaUrl,
                  autoPlay: true,
                  showControls: true,
                ),
              );
            } else {
              return PhotoView(
                imageProvider:
                    _getImageProvider(AppConfig.getFullImageUrl(mediaUrl)),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: '${widget.heroTag ?? 'media'}-$index',
                ),
              );
            }
          },
        ),
      ),
    );
  }

  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v'];
    final lowerUrl = url.toLowerCase();
    return videoExtensions.any((ext) => lowerUrl.contains(ext)) ||
        lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('vimeo.com');
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (AppConfig.isDataUri(imageUrl)) {
      // Handle base64 data URI
      try {
        final parts = imageUrl.split(',');
        if (parts.length == 2) {
          final base64Data = parts[1];
          final bytes = base64Decode(base64Data);
          return MemoryImage(bytes);
        }
      } catch (e) {
        AppLogger.error('Failed to decode base64 image', error: e);
      }
    }
    return NetworkImage(imageUrl);
  }
}
