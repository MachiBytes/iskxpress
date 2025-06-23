import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/get_verified_button.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/user_profile_picture.dart';

class UserProfileTopSection extends StatelessWidget {
  const UserProfileTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserProfilePicture(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mark Achiles G. Flores Jr.',
                      softWrap: true,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unverified',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.email, color: colorScheme.onPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'juansdelacruz@iskolarngbayan.pup.edu.ph',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GetVerifiedButton(),
        ],
      ),
    );
  }
}