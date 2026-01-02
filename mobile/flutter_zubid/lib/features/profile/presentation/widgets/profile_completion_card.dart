import 'package:flutter/material.dart';

import '../../data/models/profile_model.dart';

class ProfileCompletionCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback? onCompletePressed;

  const ProfileCompletionCard({
    super.key,
    required this.profile,
    this.onCompletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completionPercentage = profile.profileCompletionPercentage;

    return Card(
      elevation: 2,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Complete Your Profile',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${completionPercentage.toInt()}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            LinearProgressIndicator(
              value: completionPercentage / 100,
              backgroundColor: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimaryContainer,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'A complete profile helps build trust with other users and improves your bidding success.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Missing Fields
            _buildMissingFields(context),
            
            const SizedBox(height: 16),
            
            // Complete Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCompletePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onPrimaryContainer,
                  foregroundColor: theme.colorScheme.primaryContainer,
                  elevation: 0,
                ),
                child: const Text('Complete Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingFields(BuildContext context) {
    final theme = Theme.of(context);
    final missingFields = <String>[];

    // Check for missing essential fields
    if (profile.firstName == null || profile.firstName!.isEmpty) {
      missingFields.add('First Name');
    }
    if (profile.lastName == null || profile.lastName!.isEmpty) {
      missingFields.add('Last Name');
    }
    if (profile.phoneNumber == null || profile.phoneNumber!.isEmpty) {
      missingFields.add('Phone Number');
    }
    if (profile.profilePhotoUrl == null || profile.profilePhotoUrl!.isEmpty) {
      missingFields.add('Profile Photo');
    }
    if (profile.address == null || profile.address!.isEmpty) {
      missingFields.add('Address');
    }
    if (profile.city == null || profile.city!.isEmpty) {
      missingFields.add('City');
    }
    if (profile.country == null || profile.country!.isEmpty) {
      missingFields.add('Country');
    }
    if (profile.dateOfBirth == null) {
      missingFields.add('Date of Birth');
    }
    if (profile.bio == null || profile.bio!.isEmpty) {
      missingFields.add('Bio');
    }
    if (!profile.emailVerified) {
      missingFields.add('Email Verification');
    }
    if (profile.phoneNumber != null && !profile.phoneVerified) {
      missingFields.add('Phone Verification');
    }
    if (profile.idNumber == null || profile.idNumber!.isEmpty) {
      missingFields.add('ID Number');
    }

    if (missingFields.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show only first 3 missing fields to avoid clutter
    final displayFields = missingFields.take(3).toList();
    final remainingCount = missingFields.length - displayFields.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Missing Information:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ...displayFields.map((field) => _buildMissingFieldChip(context, field)),
            if (remainingCount > 0)
              _buildMissingFieldChip(context, '+$remainingCount more'),
          ],
        ),
      ],
    );
  }

  Widget _buildMissingFieldChip(BuildContext context, String field) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        field,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
