import 'package:flutter/material.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/app_logo.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/general_actions.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/logout_button.dart';
import 'package:iskxpress/presentation/pages/user_profile/widgets/my_orders.dart';

class UserProfileBottomSection extends StatelessWidget {
  const UserProfileBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  MyOrders(),
                  const SizedBox(height: 16),
                  GeneralActions(),
                ],
              ),
              Column(
                children: [
                  LogoutButton(),
                  const SizedBox(height: 8,),
                  AppLogo(),
                ],
              )              
            ],
          ),
        ),
      ),
    );
  }
}