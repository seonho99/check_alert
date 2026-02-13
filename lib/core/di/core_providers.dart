import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../services/local_notification_service.dart';

/// Core Provider (Firebase 인스턴스, 서비스)
List<SingleChildWidget> buildCoreProviders() {
  return [
    Provider<FirebaseFirestore>(
      create: (_) => FirebaseFirestore.instance,
    ),
    Provider<FirebaseAuth>(
      create: (_) => FirebaseAuth.instance,
    ),
    Provider<LocalNotificationService>(
      create: (_) => LocalNotificationService(),
    ),
  ];
}
