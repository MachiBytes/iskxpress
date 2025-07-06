import 'package:flutter/material.dart';
import 'package:iskxpress/core/services/user_state_service.dart';
import 'package:iskxpress/core/models/user_model.dart';
import 'package:iskxpress/core/services/user_api_service.dart';

class PremiumInfoPage extends StatelessWidget {
  const PremiumInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userStateService = UserStateService();
    
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        title: const Text('Premium', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: userStateService,
          builder: (context, child) {
            final UserModel? user = userStateService.currentUser;
            final bool isPremium = user?.premium ?? false;
            
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.star_rounded, 
                    size: 80, 
                    color: isPremium ? Colors.amber.shade700 : Colors.grey.shade400
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPremium ? 'You are now a Premium User' : 'Become a Premium User',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      isPremium 
                        ? 'Enjoy your benefits!' 
                        : 'Unlock exclusive benefits and elevate your IskXPRESS experience!',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _PremiumBenefit(
                    icon: Icons.local_shipping_rounded,
                    title: 'Free Deliveries',
                    description: 'Enjoy unlimited free deliveries on all your orders.',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  _PremiumBenefit(
                    icon: Icons.percent_rounded,
                    title: '10% Off Everything',
                    description: 'Get 10% off across all products in the app.',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 20),
                  _PremiumBenefit(
                    icon: Icons.verified_rounded,
                    title: 'Priority Support',
                    description: 'Access to priority customer support.',
                    color: Colors.blue,
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final success = await UserApiService.togglePremium(user!.id);
                            if (success) {
                              // Refresh user data to get updated premium status
                              await userStateService.refreshUserData();
                              
                              if (isPremium) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Premium subscription cancelled.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Congratulations! You are now a Premium user.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to update premium status. Please try again.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPremium ? Colors.red : colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isPremium ? Icons.cancel : Icons.star_rounded, 
                              color: isPremium ? Colors.white : Colors.amber.shade700
                            ),
                            const SizedBox(width: 10),
                            Text(isPremium ? 'Stop Premium' : 'Get Premium'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PremiumBenefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _PremiumBenefit({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 32),
        Icon(icon, size: 36, color: color),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
      ],
    );
  }
} 