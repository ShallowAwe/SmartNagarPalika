// screens/complaint_registration_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_nagarpalika/Model/coplaintModel.dart';
import 'package:smart_nagarpalika/Model/departmentModel.dart';
import 'package:smart_nagarpalika/Model/ward_model.dart';
import 'package:smart_nagarpalika/Screens/ComplaintsScreen.dart';
import 'package:smart_nagarpalika/Services/camera_service.dart';
import 'package:smart_nagarpalika/Services/complaintService.dart';
import 'package:smart_nagarpalika/Services/department_service.dart';
import 'package:smart_nagarpalika/Services/wards_service.dart';
import 'package:smart_nagarpalika/utils/formValidator.dart';
import 'package:smart_nagarpalika/widgets/mapWidget.dart';

class ComplaintRegistrationScreen extends StatefulWidget {
  const ComplaintRegistrationScreen({super.key});

  @override
  State<ComplaintRegistrationScreen> createState() =>
      _ComplaintRegistrationScreenState();
}

class _ComplaintRegistrationScreenState
    extends State<ComplaintRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  List<XFile>? _mediaFiles = [];
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();

  Position? _currentLocation;
  bool _isSubmitting = false;
  List<String> _attachments = [];
  Department? _selectedDepartment;
  WardModel? _selectedWard;
  List<Department> _departments = [];
  List<WardModel> _wards = [];

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

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
    _fetchWards();
  }

  Future<void> _handleFileUpload() async {
    if (_mediaFiles!.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maximum 5 files allowed')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No file selected')));
    }
  }

  Future<void> _fetchDepartments() async {
    final departments = await DepartmentService.instance.getDepartments();
    setState(() {
      _departments = departments;
    });
  }

  Future<void> _fetchWards() async {
    final wards = await WardsService.instance.getWards();
    setState(() {
      _wards = wards;
    });
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a complaint category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please wait for location to be detected or allow location access',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final complaint = ComplaintModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text.trim(),
        departmentId: _selectedDepartment!.id,
        wardId: _selectedWard!.id,
        address: _addressController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty
            ? null
            : _landmarkController.text.trim(),
        location: LocationData.fromPosition(_currentLocation!),
        attachments: List<String>.from(_attachments),
        createdAt: DateTime.now(),
      );

      await ComplaintService.instance.submitComplaint(complaint, "user1");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();

        // Navigate to complaints screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Complaintsscreen(department: _departments),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit complaint: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _descriptionController.clear();
    _addressController.clear();
    _landmarkController.clear();
    _formKey.currentState?.reset();
    setState(() {
      _selectedDepartment = null;
      _selectedWard = null;
      _attachments.clear();
      _mediaFiles = [];
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
              _buildSubmitButton(),
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
          decoration: _buildInputDecoration(
            'Enter your complaint here (तुमची तक्रार प्रविष्ट करा)',
          ),
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
        DropdownButtonFormField<Department>(
          decoration: _buildInputDecoration('Select department'),
          value: _selectedDepartment,
          items: _departments
              .map(
                (department) => DropdownMenuItem<Department>(
                  value: department,
                  child: Text(department.name),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedDepartment = value;
            });
          },
          validator: (value) =>
              value == null ? 'Please select a department' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<WardModel>(
          decoration: _buildInputDecoration("Choose your ward"),
          items: _wards
              .map(
                (ward) => DropdownMenuItem<WardModel>(
                  value: ward,
                  child: Text(ward.wardName.toString()),
                ),
              )
              .toList(),
          value: _selectedWard,
          onChanged: (value) {
            setState(() {
              _selectedWard = value;
            });
          },
          validator: (value) => value == null ? 'Please select a ward' : null,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
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
          decoration: _buildInputDecoration(
            'Enter your address (तुमचा पत्ता प्रविष्ट करा)',
          ),
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
          decoration: _buildInputDecoration(
            'Enter landmark (लँडमार्क एंटर करा)',
          ),
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
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 20,
                ),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitComplaint,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                'Submit Complaint',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    return Text(label, style: const TextStyle(fontWeight: FontWeight.w500));
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
