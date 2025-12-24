import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/profile_model.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel? profile;
  final bool isLoading;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    this.profile,
    this.isLoading = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Photo and Basic Info
            Row(
              children: [
                // Profile Photo
                _buildProfilePhoto(context),
                
                const SizedBox(width: 16),
                
                // Basic Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoading) ...[
                        _buildShimmerText(context, width: 120, height: 20),
                        const SizedBox(height: 4),
                        _buildShimmerText(context, width: 160, height: 16),
                        const SizedBox(height: 8),
                        _buildShimmerText(context, width: 100, height: 14),
                      ] else if (profile != null) ...[
                        Text(
                          profile!.displayName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${profile!.username}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Member for ${profile!.membershipDuration}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Edit Button
                if (!isLoading)
                  IconButton(
                    onPressed: onEditPressed,
                    icon: const Icon(Icons.edit_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Bio
            if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  profile!.bio!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Verification Status
            if (profile != null)
              _buildVerificationStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhoto(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: const CircularProgressIndicator(),
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: profile?.profilePhotoUrl != null
            ? CachedNetworkImage(
                imageUrl: profile!.profilePhotoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => _buildDefaultAvatar(context),
              )
            : _buildDefaultAvatar(context),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Text(
          profile?.initials ?? '?',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStatus(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Email Verification
        _buildVerificationChip(
          context,
          icon: Icons.email_outlined,
          label: 'Email',
          isVerified: profile!.emailVerified,
        ),
        
        const SizedBox(width: 8),
        
        // Phone Verification
        if (profile!.phoneNumber != null)
          _buildVerificationChip(
            context,
            icon: Icons.phone_outlined,
            label: 'Phone',
            isVerified: profile!.phoneVerified,
          ),
      ],
    );
  }

  Widget _buildVerificationChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isVerified,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified 
            ? theme.colorScheme.primaryContainer 
            : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : icon,
            size: 14,
            color: isVerified 
                ? theme.colorScheme.onPrimaryContainer 
                : theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isVerified 
                  ? theme.colorScheme.onPrimaryContainer 
                  : theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerText(BuildContext context, {required double width, required double height}) {
    final theme = Theme.of(context);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
