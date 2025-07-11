import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_nagarpalika/Model/coplaintModel.dart';
import 'package:smart_nagarpalika/Screens/complaintRegistrationScreen.dart';

class Complaintsscreen extends StatefulWidget {
  final List<ComplaintModel> complaints;
  const Complaintsscreen({super.key, required this.complaints});

  @override
  State<Complaintsscreen> createState() => _ComplaintsscreenState();
}

class _ComplaintsscreenState extends State<Complaintsscreen> {
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Your Complaints')),
    body: widget.complaints.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No complaints yet'),
                const SizedBox(height: 12),
                IconButton(
                  icon: const Icon(Icons.add, size: 32),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ComplaintRegistrationScreen(),
                      ),
                    );
                  },
                ),
                const Text('Add your first complaint'),
              ],
            ),
          )
        : ListView.builder(
            itemCount: widget.complaints.length,
            itemBuilder: (context, index) {
              return buildComplaintCard(widget.complaints[index]);
            },
          ),
  );
}


Widget buildComplaintCard(ComplaintModel complaint) {
  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () => _showComplaintDetailsPopup(complaint),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image preview
            if (complaint.attachments.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(complaint.attachments.first),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade300,
                ),
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(complaint.createdAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    complaint.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}
void _showComplaintDetailsPopup(ComplaintModel complaint) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Complaint Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildDetailRow('Date:', _formatDate(complaint.createdAt)),
            _buildDetailRow('Category:', complaint.category),
            _buildDetailRow('Address:', complaint.address),
            if (complaint.landmark != null)
              _buildDetailRow('Landmark:', complaint.landmark!),
            const SizedBox(height: 8),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(complaint.description),
            const SizedBox(height: 16),
            const Text('Attached Images:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (complaint.attachments.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: complaint.attachments.map((path) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              )
            else
              const Text('No images attached.'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
String _formatDate(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}/'
         '${dateTime.month.toString().padLeft(2, '0')}/'
         '${dateTime.year}';
}
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
}