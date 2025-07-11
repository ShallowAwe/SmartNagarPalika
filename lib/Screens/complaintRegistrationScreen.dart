// screens/complaint_registration_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_nagarpalika/Model/coplaintModel.dart';
import 'package:smart_nagarpalika/Screens/ComplaintsScreen.dart';
import 'package:smart_nagarpalika/Services/camera_service.dart';
// import 'package:smart_nagarpalika/Services/complaintService.dart';
import 'package:smart_nagarpalika/utils/formValidator.dart';
import 'package:smart_nagarpalika/widgets/mapWidget.dart';


class ComplaintRegistrationScreen extends StatefulWidget {
  const ComplaintRegistrationScreen({super.key});

  @override
  State<ComplaintRegistrationScreen> createState() =>
      _ComplaintRegistrationScreenState();
}

class _ComplaintRegistrationScreenState extends State<ComplaintRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
 //final  _complaintService = ComplaintService;// we use the singleton instance directly/../././
  // List od images./././
   List<XFile>? _mediaFiles = []; 
// List of complaints
  List<ComplaintModel> complaints = [];
  // Form controllers
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  
  // Form state
  String? _selectedCategory;
  Position? _currentLocation;
  bool _isSubmitting = false;
  List<String> _attachments = [];

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _onLocationChanged(Position? position) {
    setState(() {
      _currentLocation = position;
    });
  }

  Future<void> _handleFileUpload() async {
  if (_mediaFiles!.length >= 5) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Maximum 5 files allowed')),
    );
    return;
  }

  final status = await Permission.camera.request();
  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera permission is required')),
    );
    return;
  }

  final XFile? pickedFile = await CameraService().pickFromCamera();

  if (pickedFile != null) {
    setState(() {
      _mediaFiles!.add(pickedFile);
      _attachments.add(pickedFile.path);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File attached successfully!')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No file selected')),
    );
  }
}

List<ComplaintModel> _submmitComplaint() {
  final complaint = ComplaintModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    description: _descriptionController.text.trim(),
    category: _selectedCategory!,
    address: _addressController.text.trim(),
    landmark: _landmarkController.text.trim().isEmpty 
        ? null 
        : _landmarkController.text.trim(),
    location: LocationData.fromPosition(_currentLocation!),
    attachments: _attachments,
    createdAt: DateTime.now(),
  
  );
  complaints.add(complaint);
  return complaints;
}

// when we ready to apply back end    remeber to check this first Ok
  // Future<void> _submitComplaint() async {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   if (_currentLocation == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please wait for location to be detected or allow location access'),
  //         backgroundColor: Colors.orange,
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isSubmitting = true;
  //   });

  //   try {
  //     final complaint = ComplaintModel(
  //       id: DateTime.now().millisecondsSinceEpoch.toString(),
  //       description: _descriptionController.text.trim(),
  //       category: _selectedCategory!,
  //       address: _addressController.text.trim(),
  //       landmark: _landmarkController.text.trim().isEmpty 
  //           ? null 
  //           : _landmarkController.text.trim(),
  //       location: LocationData.fromPosition(_currentLocation!),
  //       attachments: _attachments,
  //       createdAt: DateTime.now(),
  //     );

  //     await ComplaintService.instance.submitComplaint(complaint);

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Complaint submitted successfully!'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );

  //       // Clear form
  //       _clearForm();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to submit complaint: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isSubmitting = false;
  //       });
  //     }
  //   }
  // }

  void _clearForm() {
    _descriptionController.clear();
    _addressController.clear();
    _landmarkController.clear();
    setState(() {
      _selectedCategory = null;
      _attachments.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFF6FA),
      appBar: AppBar(
        
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('Complaint Registration'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildCategoryField(),
              const SizedBox(height: 16),
              _buildFileUploadSection(),
              const SizedBox(height: 16),
              _buildAddressField(),
              const SizedBox(height: 16),
              _buildLandmarkField(),
              const SizedBox(height: 16),
              _buildLocationSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(complaints),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel('Describe the complaint (तक्रारीचे वर्णन करा)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLength: 250,
          maxLines: 5,
          decoration: _buildInputDecoration('Enter your complaint here (तुमची तक्रार प्रविष्ट करा)'),
          validator: FormValidator.validateDescription,
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel('Complaint Category (तक्रार श्रेणी)'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Select category'),
          value: _selectedCategory,
          items: ComplaintCategory.allCategories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: FormValidator.validateCategory,
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1DD1A1), Color(0xFF54A0FF)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton.icon(
          onPressed: _handleFileUpload,
          icon: const Icon(Icons.attach_file),
          label: const Text('Add File (फाइल जोडा)'),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      const SizedBox(height: 10),
      if (_mediaFiles!.isNotEmpty)
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _mediaFiles!
              .asMap()
              .entries
              .map(
                (entry) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(entry.value.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _attachments.remove(entry.value.path);
                          _mediaFiles?.removeAt(entry.key);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    )
                  ],
                ),
              )
              .toList(),
        ),
    ],
  );
}



  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel('Enter Address (पत्ता प्रविष्ट करा)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          decoration: _buildInputDecoration('Enter your address (तुमचा पत्ता प्रविष्ट करा)'),
          validator: FormValidator.validateAddress,
        ),
      ],
    );
  }

  Widget _buildLandmarkField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Enter the landmark (लँडमार्क प्रविष्ट करा)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _landmarkController,
          decoration: _buildInputDecoration('Enter landmark (लँडमार्क एंटर करा)'),
          validator: FormValidator.validateLandmark,
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        _buildLabel('Your Current Location (तुमच वर्तमान स्थान)'),
        const SizedBox(height: 8),
        MapWidget(
          height: 200,
          onLocationChanged: _onLocationChanged,
          showMyLocationButton: true,
          showZoomControls: false,
          initialZoom: 16.0,
        ),
        if (_currentLocation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location captured: ${_currentLocation!.latitude.toStringAsFixed(6)}, ${_currentLocation!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton( List<ComplaintModel> complaints) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : () async {
          _submmitComplaint();
  final result = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) =>  Complaintsscreen(complaints: complaints,),
    ),
  );

  if (result == true) {
    setState(() {
      // Reload complaints list from service (if using a real DB or API, fetch again) 
      print("THE COMPLAINTS $complaints");
    });
  }
},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: const Color.fromARGB(255, 86, 240, 119),
          foregroundColor: const Color.fromARGB(179, 54, 54, 54),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Submit Complaint (तक्रार सबमिट करा)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
              ),
      ),
    );
  }

  Widget _buildRequiredLabel(String label) {
    return Row(
      children: [
        const Text('*', style: TextStyle(color: Colors.red)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w500),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: const Color.fromARGB(255, 189, 189, 189)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}