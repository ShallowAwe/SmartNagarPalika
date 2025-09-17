  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:smart_nagarpalika/Model/alert_model.dart';
  import 'package:smart_nagarpalika/Services/alert_service.dart';
  import 'package:smart_nagarpalika/provider/alert_notifier.dart';
  import 'package:smart_nagarpalika/provider/auth_provider.dart';


  final alertServiceProvider = Provider<AlertService>((ref) {
    return AlertService();
  });

  final alertsProvider =
      StateNotifierProvider<AlertsNotifier, AsyncValue<List<Alertmodel>>>((ref) {
    final auth = ref.watch(authProvider);
    final service = ref.watch(alertServiceProvider);
    return AlertsNotifier(service, auth!.username, auth.password);
  });
