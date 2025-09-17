import 'package:flutter/material.dart';
import 'package:smart_nagarpalika/Screens/redirectingScreen.dart';
// import 'package:smart_nagarpalika/Screens/webview_screen.dart';

class ServiceGridItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final String? url;
  final Widget? screen;

  const ServiceGridItem({
    super.key,
    required this.imagePath,
    required this.label,
    this.url,
    this.screen,
  });

  void _handleTap(BuildContext context) {
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen!),
      );
    } else if (url != null && url!.isNotEmpty && Uri.tryParse(url!) != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebViewScreen(url: url!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No action assigned")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 10,
      shadowColor: const Color.fromARGB(161, 0, 0, 0),
      child: InkWell(
        splashColor: const Color.fromARGB(71, 0, 0, 0),
        borderRadius: BorderRadius.circular(14),
        onTap: () => _handleTap(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Service icon
              Expanded(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  width: 40,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              /// Service label
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
