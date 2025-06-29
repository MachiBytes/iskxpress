import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePicture extends StatelessWidget {
  final String? pictureUrl;

  const UserProfilePicture({
    super.key,
    this.pictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: pictureUrl != null && pictureUrl!.isNotEmpty
            ? Image.network(
                pictureUrl!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // If image fails to load, show default avatar
                  return _buildDefaultAvatar(colorScheme);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  );
                },
              )
            : _buildDefaultAvatar(colorScheme),
      ),
    );
  }

  Widget _buildDefaultAvatar(ColorScheme colorScheme) {
    return Icon(
      Icons.person,
      size: 40,
      color: colorScheme.primary,
    );
  }
}