import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_nagarpalika/Screens/ComplaintsScreen.dart';

final List<Map<String, dynamic>> quickServices = [
  {'label': 'Complaint', 'imagePath': 'lib/assets/complaint.png', 'onTap': () {
      // Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => Complaintsscreen()));
  }},
  {'label': 'Certificates', 'imagePath': 'lib/assets/Certificates.png', 'onTap': () {}},
  {'label': 'News', 'imagePath': 'lib/assets/news.png', 'onTap': () {}},
  {'label': 'Help Desk', 'imagePath': 'lib/assets/helpDesk.png', 'onTap': () {}},
  {'label': 'Tree Trimming', 'imagePath': 'lib/assets/treeTreaming.png', 'onTap': () {}},
  {'label': 'Water Bill', 'imagePath': 'lib/assets/WaterTax.png', 'onTap': () {}},
  {'label': 'Property Tax', 'imagePath': 'lib/assets/PropertyTax.png', 'onTap': () {}},
  {'label': 'Electricity Bill', 'imagePath': 'lib/assets/lightBill.png', 'onTap': () {}},
];

final List<Map<String, dynamic>> popularServices = [
  {'label': 'Tree Trimming', 'imagePath': 'lib/assets/treeTreaming.png', 'onTap': () {}},
  {'label': 'Water Bill', 'imagePath': 'lib/assets/WaterTax.png', 'onTap': () {}},
  {'label': 'Property Tax', 'imagePath': 'lib/assets/PropertyTax.png', 'onTap': () {}},
  {'label': 'Electricity Bill', 'imagePath': 'lib/assets/lightBill.png', 'onTap': () {}},
  
];
