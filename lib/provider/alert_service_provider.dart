import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_nagarpalika/Model/alert_model.dart';
import 'package:smart_nagarpalika/Services/alert_service.dart';
import 'package:smart_nagarpalika/provider/auth_provider.dart';

final alertsProvider = FutureProvider<List<Alertmodel>>((ref) async {
  final service = AlertService();
  final auth = ref.watch(authProvider);

  if (auth == null) throw Exception("Not logged in");

  return service.fetchAlerts(auth.username, auth.password);
});
