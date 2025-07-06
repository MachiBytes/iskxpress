import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/user_profile_picture.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/models/user_model.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/get_premium_button.dart';

class UserProfileTopSection extends StatefulWidget {
  const UserProfileTopSection({super.key});

  @override
  State<UserProfileTopSection> createState() => _UserProfileTopSectionState();
}

class _UserProfileTopSectionState extends State<UserProfileTopSection> {
  final UserStateService _userStateService = UserStateService();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  Future<void> _refreshUserData() async {
    if (!mounted) return;
    
    setState(() {
      _isRefreshing = true;
    });

    await _userStateService.refreshUserData();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return AnimatedBuilder(
      animation: _userStateService,
      builder: (context, child) {
        final UserModel? user = _userStateService.currentUser;
        final bool isLoading = _userStateService.isLoading || _isRefreshing;
        
        if (isLoading) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
              ),
            ),
          );
        }

        if (user == null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Unable to load user profile',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _refreshUserData,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  UserProfilePicture(pictureUrl: user.pictureUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                          user.name,
                      softWrap: true,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                          user.premium ? 'Premium' : 'Standard',
                      style: textTheme.bodySmall?.copyWith(
                            color: user.premium 
                            ? Colors.amber 
                            : colorScheme.onPrimary,
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
                      user.email,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
              GetPremiumButton(),
        ],
      ),
        );
      },
    );
  }
}