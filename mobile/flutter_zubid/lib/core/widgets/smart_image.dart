import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../config/app_config.dart';

/// A smart image widget that handles both network URLs and data URIs (base64).
/// 
/// This widget automatically detects the type of image URL and renders it
/// appropriately:
/// - For data URIs (base64): Uses Image.memory
/// - For network URLs: Uses CachedNetworkImage for caching
class SmartImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = AppConfig.getFullImageUrl(imageUrl);

    // Default placeholder
    final defaultPlaceholder = Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    // Default error widget
    final defaultErrorWidget = Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );

    // If URL is empty, show error widget
    if (url.isEmpty) {
      return _wrapWithBorderRadius(errorWidget ?? defaultErrorWidget);
    }

    // Check if it's a data URI
    if (AppConfig.isDataUri(url)) {
      return _buildDataUriImage(
        url,
        defaultPlaceholder,
        defaultErrorWidget,
      );
    }

    // Network image with caching
    return _wrapWithBorderRadius(
      CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => placeholder ?? defaultPlaceholder,
        errorWidget: (context, url, error) => errorWidget ?? defaultErrorWidget,
      ),
    );
  }

  Widget _buildDataUriImage(
    String dataUri,
    Widget defaultPlaceholder,
    Widget defaultErrorWidget,
  ) {
    try {
      // Extract base64 data from data URI
      // Format: data:image/png;base64,<base64_data>
      final parts = dataUri.split(',');
      if (parts.length != 2) {
        return _wrapWithBorderRadius(errorWidget ?? defaultErrorWidget);
      }

      final base64Data = parts[1];
      final Uint8List bytes = base64Decode(base64Data);

      return _wrapWithBorderRadius(
        Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? defaultErrorWidget;
          },
        ),
      );
    } catch (e) {
      return _wrapWithBorderRadius(errorWidget ?? defaultErrorWidget);
    }
  }

  Widget _wrapWithBorderRadius(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }
}

