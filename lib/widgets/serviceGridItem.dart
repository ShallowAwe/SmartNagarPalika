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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (screen != null) {
          // Navigate to Flutter screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen!),
          );
        } else if (url != null && url!.isNotEmpty) {
          // Navigate to WebView
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewScreen(
                url: url!,
                // title: label,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("No action assigned")));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withAlpha(125),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(imagePath, fit: BoxFit.contain, width: 40),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
