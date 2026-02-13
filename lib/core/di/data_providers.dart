import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/datasource/auth_datasource.dart';
import '../../data/datasource/auth_firebase_datasource_impl.dart';
import '../../data/datasource/task_datasource.dart';
import '../../data/datasource/task_firebase_datasource_impl.dart';

/// Data Provider (DataSource 구현체)
List<SingleChildWidget> buildDataProviders() {
  return [
    Provider<AuthDataSource>(
      create: (context) => AuthFirebaseDataSourceImpl(
        auth: context.read<FirebaseAuth>(),
        firestore: context.read<FirebaseFirestore>(),
        googleSignIn: GoogleSignIn.instance,
      ),
    ),
    Provider<TaskDataSource>(
      create: (context) => TaskFirebaseDataSourceImpl(
        firestore: context.read<FirebaseFirestore>(),
      ),
    ),
  ];
}
