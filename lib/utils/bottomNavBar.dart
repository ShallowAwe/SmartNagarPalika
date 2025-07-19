import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              title: 'Home',
              imagePath: 'lib/assets/homeUnSelected.png',
              onTap: () {
                // Navigate to Home
              },
            ),
            _NavItem(
              title: 'Near Mw',
              imagePath: 'lib/assets/nearMe.png',
              onTap: () {
                // Navigate to Near Me
              },
            ),
            _NavItem(
              title: 'Services',
              imagePath: 'lib/assets/Seervices (1).png', // Make sure you rename this file
              onTap: () {
                // Navigate to Services
              },
            ),
            _NavItem(
              title: 'Profile',

              imagePath: 'lib/assets/profile.png',
              onTap: () {
                // Navigate to Profile
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable nav item with tap animation
class _NavItem extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final String title;

  const _NavItem({
    required this.imagePath,
    required this.onTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Image.asset(imagePath, width: 30, height: 30),
           Text(
  title,
  style: const TextStyle(
    fontSize: 10,
    color: Colors.black87,
    fontWeight: FontWeight.w500,
  ),
),

          ],
        )
       
      ),
    );
  }
}
