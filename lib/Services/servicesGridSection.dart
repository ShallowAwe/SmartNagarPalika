import 'package:flutter/material.dart';
import 'package:smart_nagarpalika/widgets/serviceGridItem.dart';

class ServiceGridSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> services;

  const ServiceGridSection({
    super.key,
    required this.title,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Changed from margin to padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevents extra space
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title with minimal spacing
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12), // Reduced from your padding approach
          
          /// Grid Section
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8, // Reduced spacing
              crossAxisSpacing: 8,
              childAspectRatio: 0.9, // Slightly more compact
            ),
            itemBuilder: (context, index) {
              final service = services[index];
              
            return  ServiceGridItem(
  imagePath: service['imagePath'] ?? '',
  label: service['label'] ?? '',
  url: service['url'],
  screen: service['screen'], 
);

            },
          ),
        ],
      ),
    );
  }
}