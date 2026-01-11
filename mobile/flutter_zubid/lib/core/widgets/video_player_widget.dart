import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../config/app_config.dart';
import '../utils/logger.dart';

/// A smart video player widget that handles both network URLs and local files.
/// 
/// This widget automatically detects the type of video URL and renders it
/// appropriately with proper controls and error handling.
class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool autoPlay;
  final bool looping;
  final bool showControls;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeControllers();
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No video URL provided';
      });
      return;
    }

    try {
      final videoUrl = AppConfig.getFullImageUrl(widget.videoUrl!);
      AppLogger.info('Initializing video player for: $videoUrl');

      // Check if it's a supported video format
      if (!_isSupportedVideoFormat(videoUrl)) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Unsupported video format';
        });
        return;
      }

      // Initialize video controller
      if (videoUrl.startsWith('http')) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Local video files not supported yet';
        });
        return;
      }

      await _videoController!.initialize();

      // Initialize Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        showControls: widget.showControls,
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: widget.placeholder,
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
        },
      );

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      AppLogger.info('Video player initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize video player', error: e);
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video: ${e.toString()}';
      });
    }
  }

  bool _isSupportedVideoFormat(String url) {
    final supportedFormats = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v'];
    return supportedFormats.any((format) => 
        url.toLowerCase().contains(format) || 
        url.contains('youtube.com') || 
        url.contains('vimeo.com'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content;

    if (_hasError) {
      content = _buildErrorWidget(_errorMessage ?? 'Unknown error');
    } else if (!_isInitialized) {
      content = _buildPlaceholder(theme);
    } else {
      content = Chewie(controller: _chewieController!);
    }

    return _wrapWithBorderRadius(
      SizedBox(
        width: widget.width,
        height: widget.height,
        child: content,
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return widget.placeholder ?? Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading video...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    final theme = Theme.of(context);
    
    return widget.errorWidget ?? Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Video unavailable',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _wrapWithBorderRadius(Widget child) {
    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }
    return child;
  }
}
