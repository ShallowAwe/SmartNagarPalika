import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_nagarpalika/Model/complaint_response_model.dart';
import 'package:smart_nagarpalika/Screens/complaintRegistrationScreen.dart';
import 'package:smart_nagarpalika/Screens/employee_screens/employee_profile_screen.dart';
import 'package:smart_nagarpalika/Services/logger_service.dart';
import 'package:smart_nagarpalika/provider/employee/employee_complaint_provider.dart';
import 'package:smart_nagarpalika/utils/employee/complaint_utils.dart';
import 'package:smart_nagarpalika/widgets/employee_complaint_widgets.dart';
import 'package:smart_nagarpalika/Screens/employee_screens/employee_complete_complaint_screen.dart';


/// Screen that displays employee complaints with tab-based filtering
/// Allows switching between All, Pending, In Progress, and Resolved complaints
class EmployeeComplaintViewScreen extends ConsumerStatefulWidget {
  const EmployeeComplaintViewScreen({super.key});

  @override
  ConsumerState<EmployeeComplaintViewScreen> createState() => _EmployeeComplaintViewScreenState();
}

class _EmployeeComplaintViewScreenState extends ConsumerState<EmployeeComplaintViewScreen> 
    with SingleTickerProviderStateMixin {
  
  /// Controller for managing the tab navigation
  late TabController _tabController;
  
  /// Currently selected complaint status filter
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with 3 tabs (removed pending)
    _tabController = TabController(length: 3, vsync: this);
    
    // Listen to tab changes to update the selected status
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Handles tab changes and updates the selected status filter
  void _onTabChanged() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedStatus = 'all';
          break;
        case 1:
          _selectedStatus = 'in progress';
          break;
        case 2:
          _selectedStatus = 'resolved';
          break;
      }
    });
  }

  /// Filters complaints based on the selected status
  List<ComplaintResponseModel> _filterComplaints(List<ComplaintResponseModel> complaints) {
    if (_selectedStatus == 'all') return complaints;
    
    return complaints.where((complaint) {
      final normalized = ComplaintUtils.normalizeStatus(complaint.status.toString());
      return normalized == _selectedStatus;
    }).toList();
  }

  /// Shows the complaint details popup
  void _showComplaintDetailsPopup(BuildContext context, ComplaintResponseModel complaint) {
    final status = complaint.status.toString();
    final statusColor = ComplaintUtils.getStatusColor(status);
    final statusIcon = ComplaintUtils.getStatusIcon(status);
    final normalizedStatus = ComplaintUtils.normalizeStatus(status);

    showDialog(
      context: context,
      builder: (_) => ComplaintDetailsPopup(
        complaint: complaint,
        statusColor: statusColor,
        statusIcon: statusIcon,
        normalizedStatus: normalizedStatus,
        onCompleteComplaint: () => _navigateToCompleteComplaint(context, complaint),
      ),
    );
  }

  /// Navigates to the complete complaint screen
  void _navigateToCompleteComplaint(BuildContext context, ComplaintResponseModel complaint) {
    Navigator.of(context).pop(); // Close the popup first
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeCompleteComplaintScreen(complaint: complaint),
      ),
    ).then((result) {
      // Refresh the complaints list if the complaint was completed successfully
      if (result == true) {
        ref.invalidate(empComplaintProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final logger = LoggerService.instance;
    final complaintsAsync = ref.watch(empComplaintProvider);

    return Scaffold(
      // App bar with profile button and tabs
      appBar: _buildAppBar(),
      
      // Main body with complaint list or empty state
      body: _buildBody(complaintsAsync, logger),
    );
  }

  /// Builds the app bar with title, profile button, and tab navigation
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // Profile button in the top right
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EmployeeProfileScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_2_outlined, color: Colors.blue),
            ),
          ),
        ),
      ],
      
      title: const Text('Your Complaints'),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      
      // Tab navigation below the app bar
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'In Progress'),
          Tab(text: 'Resolved'),
        ],
      ),
    );
  }

  /// Builds the main body content based on complaint data state
  Widget _buildBody(AsyncValue<List<ComplaintResponseModel>> complaintsAsync, LoggerService logger) {
    return complaintsAsync.when(
      data: (complaints) => _buildComplaintsList(complaints, logger),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorState(err, logger),
    );
  }

  /// Builds the complaints list or empty state
  Widget _buildComplaintsList(List<ComplaintResponseModel> complaints, LoggerService logger) {
    logger.debug('Complaints loaded: ${complaints.length} items');
    
    final filteredComplaints = _filterComplaints(complaints);

    if (filteredComplaints.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(empComplaintProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: EmptyComplaintsState(
              selectedStatus: _selectedStatus,
              onAddComplaint: () => _navigateToAddComplaint(),
            ),
          ),
        ),
      );
    }

    return _buildComplaintsListView(filteredComplaints, logger);
  }

  /// Builds the list view of complaints
  Widget _buildComplaintsListView(List<ComplaintResponseModel> complaints, LoggerService logger) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(empComplaintProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];
          final status = complaint.status.toString();
          final statusColor = ComplaintUtils.getStatusColor(status);
          final statusIcon = ComplaintUtils.getStatusIcon(status);
          final normalizedStatus = ComplaintUtils.normalizeStatus(status);

          return ComplaintCard(
            complaint: complaint,
            onTap: () => _showComplaintDetailsPopup(context, complaint),
            statusColor: statusColor,
            statusIcon: statusIcon,
            normalizedStatus: normalizedStatus,
          );
        },
      ),
    );
  }

  /// Builds the error state widget
  Widget _buildErrorState(Object error, LoggerService logger) {
    logger.error('Error loading complaints', error);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading complaints',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade500,
            ),
          ),
        ],
      ),
    );
  }



  /// Navigates to the complaint registration screen
  void _navigateToAddComplaint() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ComplaintRegistrationScreen(),
      ),
    );
  }
}
