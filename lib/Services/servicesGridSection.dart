import 'package:flutter/material.dart';
import 'package:smart_nagarpalika/widgets/serviceGridItem.dart';

class ServiceGridSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> services;

  const ServiceGridSection({
    super.key,
    required this.title,
    this.services = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section title
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          /// Responsive Grid
          LayoutBuilder(
            builder: (context, constraints) {
              // Adjust number of columns dynamically
              final crossAxisCount = (constraints.maxWidth ~/ 90).clamp(2, 6);

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: GridView.builder(
                  key: ValueKey(services.length), // triggers animation when data changes
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ServiceGridItem(
                      imagePath: service['imagePath'] ?? '',
                      label: service['label'] ?? '',
                      url: service['url'],
                      screen: service['screen'],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
