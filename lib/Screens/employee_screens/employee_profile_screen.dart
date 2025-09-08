import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_nagarpalika/Services/auth_services.dart';
import 'package:smart_nagarpalika/provider/employee/employee_auth_details_provider.dart';

class EmployeeProfileScreen extends ConsumerStatefulWidget {
  const EmployeeProfileScreen({super.key, this.details});

  final EmployeeDetails? details;

  @override
  ConsumerState<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends ConsumerState<EmployeeProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Prefer provider value, fallback to explicitly passed details
    final providerDetails = ref.watch(employeeDetailsProvider);
    final effectiveDetails = providerDetails ?? widget.details;

    final firstName = effectiveDetails?.firstName ?? 'Employee';
    final lastName = effectiveDetails?.lastName ?? '';
    final fullName = (firstName + ' ' + lastName).trim();
    final department = effectiveDetails?.departmentName ?? 'N/A';
    final phone = effectiveDetails?.phoneNumber ?? 'N/A';
    final wards = (effectiveDetails?.wardNames ?? const <String>[]).join(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'E',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('Department'),
                subtitle: Text(department),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(phone),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Assigned Wards'),
                subtitle: Text(wards.isEmpty ? 'N/A' : wards),
              ),
            ),
          ],
        ),
      ),
    );
  }
}