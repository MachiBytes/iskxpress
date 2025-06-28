import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePicture extends StatelessWidget {
  const UserProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    
    return CircleAvatar(
      radius: 30,
      backgroundColor: colorScheme.onPrimary,
      backgroundImage: user?.photoURL != null 
          ? NetworkImage(user!.photoURL!) 
          : null,
      child: user?.photoURL == null 
          ? Icon(
              Icons.person,
              size: 60,
              color: colorScheme.primary,
            )
          : null,
    );
  }
}