import 'package:flutter/material.dart';

class StallCard extends StatelessWidget {
  const StallCard({
    super.key,
    required this.imagePath,
    required this.stallName,
    required this.stallNumber,
    required this.stallDescription,
    this.onPressed, // Add an optional onPressed callback
  });

  final String imagePath;
  final String stallName;
  final String stallNumber;
  final String stallDescription;
  final VoidCallback? onPressed; // Optional callback for the button

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: onPressed ?? () {}, // Use provided callback or an empty function
      style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        side: WidgetStateProperty.all(
          BorderSide(
            color: colorScheme.outline.withOpacity(0.5), // Use outline color with reduced opacity
            width: 0.5, // Thinner border
          ),
        ),
        backgroundColor: WidgetStateProperty.all(colorScheme.surface), // Ensure background is surface
        foregroundColor: WidgetStateProperty.all(colorScheme.onSurface), // Ensure text color is correct
        elevation: WidgetStateProperty.all(0), // FoodPanda style often has no elevation for these cards
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 120, // Adjust image height
              width: 120, // Adjust image width
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  height: 120,
                  width: 120,
                  child: Icon(Icons.restaurant, color: colorScheme.onSurface.withOpacity(0.5)),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stallName,
                    style: textTheme.titleSmall?.copyWith( // Use titleSmall for slightly smaller text
                      fontWeight: FontWeight.w600, // Slightly lighter bold
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    stallNumber,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)), // Use bodySmall
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stallDescription,
                    style: textTheme.bodyMedium?.copyWith(height: 1.2, color: colorScheme.onSurface.withOpacity(0.8)), // Use bodySmall
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}