import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/premium_info_page.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/models/user_model.dart';

class GetPremiumButton extends StatelessWidget {
  const GetPremiumButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userStateService = UserStateService();
    
    return AnimatedBuilder(
      animation: userStateService,
      builder: (context, child) {
        final UserModel? user = userStateService.currentUser;
        final bool isPremium = user?.premium ?? false;
        
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PremiumInfoPage(),
                ),
              );
            },
            icon: Icon(
              isPremium ? Icons.star : Icons.star_border,
              color: isPremium ? Colors.amber : Colors.amber,
            ),
            label: Text(isPremium ? 'Premium Active' : 'Get Premium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPremium ? Colors.amber : colorScheme.onPrimary,
              foregroundColor: isPremium ? Colors.white : colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
} 