import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_nagarpalika/Services/auth_services.dart';

/// Holds the logged-in employee's details so they can be accessed app-wide.
final employeeDetailsProvider = StateProvider<EmployeeDetails?>(
  (ref) => null,
);

