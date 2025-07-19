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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title with tighter spacing
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          /// Grid Section
          Material(
            color: Colors.transparent,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10, // reduced spacing
                crossAxisSpacing: 10,
                childAspectRatio: 0.95, // more compact height
              ),
              itemBuilder: (context, index) {
                final service = services[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Colors.blue.withOpacity(0.2),
                  onTap: () {
                    // Optional: Add navigation or feedback here
                  },
                  child: ServiceGridItem(
                    imagePath: service['imagePath'] ?? '',
                    label: service['label'] ?? '',
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
