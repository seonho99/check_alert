import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/errors/exceptions.dart';
import '../dto/user_model_dto.dart';
import 'auth_datasource.dart';

/// Firebase 기반 Auth DataSource 구현체
class AuthFirebaseDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  bool _isGoogleSignInInitialized = false;

  AuthFirebaseDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  // ========================================
  // Firestore 변환 헬퍼 메서드
  // ========================================

  UserModelDto _documentToDto(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModelDto(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      isEmailVerified: data['isEmailVerified'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> _dtoToFirestore(UserModelDto dto) {
    return {
      'email': dto.email,
      'displayName': dto.displayName,
      'isEmailVerified': dto.isEmailVerified,
      'createdAt': dto.createdAt != null
          ? Timestamp.fromDate(dto.createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // ========================================
  // Auth 메서드
  // ========================================

  @override
  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw const ServerException('회원가입 후 사용자 정보를 가져올 수 없습니다');
      }
      return uid;
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw const ServerException('로그인 후 사용자 정보를 가져올 수 없습니다');
      }
      return uid;
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  // ========================================
  // Google 로그인
  // ========================================

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      throw ServerException('Google Sign-In 초기화 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<String> signInWithGoogle() async {
    try {
      if (!_isGoogleSignInInitialized) {
        await _initializeGoogleSignIn();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        throw const ServerException('Google 로그인이 취소되었습니다');
      }

      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;
      final authorization = await authorizationClient.authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const ServerException('Google 로그인에 실패했습니다');
      }

      return userCredential.user!.uid;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;

      final errorString = e.toString();

      if (errorString.contains('ApiException: 7') || errorString.contains('network_error')) {
        throw const NetworkException('네트워크 연결을 확인해주세요');
      }

      if (errorString.contains('ApiException: 10') || errorString.contains('DEVELOPER_ERROR')) {
        throw const ServerException('Google 로그인 설정 오류입니다. Firebase Console에서 SHA-1 인증서를 확인해주세요.');
      }

      if (errorString.contains('sign_in_canceled') || errorString.contains('SIGN_IN_CANCELLED')) {
        throw const ServerException('Google 로그인이 취소되었습니다');
      }

      throw ServerException('Google 로그인 중 오류가 발생했습니다: $e');
    }
  }

  // ========================================
  // Apple 로그인
  // ========================================

  @override
  Future<String> signInWithApple() async {
    try {
      AppleAuthProvider appleProvider = AppleAuthProvider();
      appleProvider = appleProvider.addScope('email');
      appleProvider = appleProvider.addScope('name');

      final userCredential = await _auth.signInWithProvider(appleProvider);

      if (userCredential.user == null) {
        throw const ServerException('Apple 로그인에 실패했습니다');
      }

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-cancelled' || e.toString().contains('canceled')) {
        throw const ServerException('Apple 로그인이 취소되었습니다');
      }
      rethrow;
    } catch (e) {
      if (e is ServerException) rethrow;

      if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
        throw const ServerException('Apple 로그인이 취소되었습니다');
      }

      throw ServerException('Apple 로그인 중 오류가 발생했습니다: $e');
    }
  }

  // ========================================
  // Firestore 사용자 정보
  // ========================================

  @override
  Future<void> saveUser(UserModelDto user) async {
    try {
      final uid = user.uid;
      if (uid == null || uid.isEmpty) {
        throw const ServerException('사용자 UID가 없습니다');
      }
      final data = _dtoToFirestore(user);
      await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<UserModelDto?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return _documentToDto(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  // ========================================
  // Getter / Stream
  // ========================================

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  Stream<String?> get authStateChanges {
    return _auth.authStateChanges().map((user) => user?.uid);
  }
}
