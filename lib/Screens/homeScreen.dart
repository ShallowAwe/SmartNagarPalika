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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Smart Nagarpalika"),
      //   // backgroundColor: Colors.green,
      // ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
        
          children:  [
            TopContainer(),
          const SizedBox(height:15,),
            Horizantalnewscard(),
            const SizedBox(height: 15,),
            Column(
              children: [
            ServiceGridSection(title: 'Quick Services', services: quickServices),
            ServiceGridSection(title: 'Popular Services', services: popularServices),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: SizedBox( height:96,child:  BottomNavbar()),
         
    );
  }
}