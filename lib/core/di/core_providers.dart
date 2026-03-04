import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../services/local_notification_service.dart';
import '../services/app_open_ad_service.dart';
import '../services/banner_ad_service.dart';

/// Core Provider (Firebase 인스턴스, 서비스)
List<SingleChildWidget> buildCoreProviders({
  required LocalNotificationService localNotificationService,
}) {
  return [
    Provider<FirebaseFirestore>(
      create: (_) => FirebaseFirestore.instance,
    ),
    Provider<FirebaseAuth>(
      create: (_) => FirebaseAuth.instance,
    ),
    Provider<LocalNotificationService>.value(
      value: localNotificationService,
    ),
    Provider<AppOpenAdService>(
      create: (_) => AppOpenAdService(),
      dispose: (_, service) => service.dispose(),
    ),
    Provider<BannerAdService>(
      create: (_) => BannerAdService(),
    ),
  ];
}
