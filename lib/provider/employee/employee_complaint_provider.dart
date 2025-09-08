 import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_nagarpalika/Model/complaint_response_model.dart';
import 'package:smart_nagarpalika/Services/Employee/employee_complaint_service.dart';

final empComplaintServiceProvider  = Provider(
   (ref) => EmployeeComplaintService(),
);
late final String name ;
final empComplaintProvider = FutureProvider<List<ComplaintResponseModel>>(
    (ref) async{
       final service = ref.read(empComplaintServiceProvider);
       return await service.fetchAssignedComplaints();
    }
);