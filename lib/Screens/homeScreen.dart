import 'package:flutter/material.dart';
import 'package:smart_nagarpalika/Data/gridData.dart';
import 'package:smart_nagarpalika/Services/servicesGridSection.dart';
import 'package:smart_nagarpalika/utils/bottomNavBar.dart';
import 'package:smart_nagarpalika/utils/topContainer.dart';
import 'package:smart_nagarpalika/widgets/horizantalNewsCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isNearmeSelected = false;
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Container
            const TopContainer(),
            
            const SizedBox(height: 16), // Consistent spacing
            
            // News Card Section
            const Horizantalnewscard(),
            
            const SizedBox(height: 20), // Slightly more space before services
            
            // Services Sections
            ServiceGridSection(
              title: 'Quick Services', 
              services: quickServices,
            ),
            
            const SizedBox(height: 24), // Space between sections
            
             ServiceGridSection(
              title: 'Popular Services', 
              services: popularServices,
            ),
            
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
      bottomNavigationBar:  SizedBox(
        height: 96,
        child: BottomNavbar(
          isNearmeSelected: _isNearmeSelected,
        ),
      ),
    );
  }
}