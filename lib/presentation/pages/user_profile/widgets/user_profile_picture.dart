import 'package:flutter/material.dart';

class UserProfilePicture extends StatelessWidget {
  const UserProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return CircleAvatar(
      radius: 30,
      backgroundColor: colorScheme.onPrimary,
      child: Icon(
        Icons.person,
        size: 60,
        color: colorScheme.primary,
      ),
    );
  }
}