import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_nagarpalika/provider/alert_service_provider.dart';
import 'package:smart_nagarpalika/provider/auth_provider.dart';
import 'package:smart_nagarpalika/widgets/notification_popUpwidget.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsyncValue = ref.watch(alertsProvider);
    final authState = ref.watch(authProvider);

    // Handle null auth state
    if (authState == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Authentication required",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final String username = authState.username;
    final String password = authState.password;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 229, 243),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(alertsProvider);
            },
          ),
        ],
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No notifications found.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
     return GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, // 2 items per row
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    mainAxisExtent: 280, // fixed height per card
  ),
  padding: const EdgeInsets.all(12),
  itemCount: notifications.length,
  itemBuilder: (context, index) {
    final notification = notifications[index];
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                content: NotificationPopupWidget(
                  notification: notification,
                ),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or fallback
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: notification.imageUrl != null &&
                        notification.imageUrl!.isNotEmpty
                    ? Image.network(
                        notification.imageUrl!,
                        headers: {
                          "Authorization":
                              "Basic ${base64Encode(utf8.encode('$username:$password'))}",
                        },
                        width: double.infinity,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackIcon(),
                      )
                    : _buildFallbackIcon(),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                notification.title ?? 'No Title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                notification.description ?? 'No Description',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),

              // Bottom: Date + Chip (no overflow, thanks to Wrap)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    notification.createdAt ?? 'Unknown date',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Chip(
                    label: Text(
                      notification.type ?? 'General',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTextColor(notification.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: _getChipColor(notification.type),
                    elevation: 4,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
);

        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Loading notifications...",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading notifications',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(alertsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.notifications,
        color: Colors.grey,
        size: 40,
      ),
    );
  }

  // Helper function to get chip color based on type
  Color _getChipColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'alerts':
        return Colors.red;
      case 'articles':
        return Colors.blue;

      default:
        return Colors.grey.shade100;
    }
  }

  // Helper function to get text color based on type
  Color _getTextColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'alerts':
      case 'articles':
      case 'warning':
        return Colors.white;
      case 'info':
      case 'success':
        return Colors.black87;
      default:
        return Colors.black87;
    }
  }
}
