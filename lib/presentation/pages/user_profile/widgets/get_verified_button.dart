import 'package:flutter/material.dart';

class GetVerifiedButton extends StatelessWidget {
  final bool isVerified;

  const GetVerifiedButton({
    super.key,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Don't show the button if user is already verified
    if (isVerified) {
      return const SizedBox.shrink();
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement verification process
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification process not yet implemented'),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.onPrimary,
          foregroundColor: colorScheme.primary,
        ),
        child: const Text('Get Verified'),
      ),
    );
  }
}