import 'package:firebase_auth/firebase_auth.dart';

import '../../core/errors/failure.dart';
import '../../core/errors/failure_mapper.dart';
import '../../core/result/result.dart';
import '../../domain/model/user_model.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_datasource.dart';
import '../mapper/user_model_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl({
    required AuthDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (email.trim().isEmpty) {
        return const Error(ValidationFailure('이메일은 필수입니다'));
      }
      if (password.trim().isEmpty) {
        return const Error(ValidationFailure('비밀번호는 필수입니다'));
      }
      if (password.length < 6) {
        return const Error(ValidationFailure('비밀번호는 6자 이상이어야 합니다'));
      }

      // Firebase Auth 회원가입
      final uid = await _dataSource.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Mapper로 UserModel 생성
      final user = uid.toUserModelWithUid(
        email: email.trim().toLowerCase(),
        displayName: displayName?.trim(),
        isEmailVerified: false,
      );

      // Firestore에 사용자 정보 저장 (비동기)
      final userDto = user.toDto();
      _dataSource.saveUser(userDto).catchError((e) {
        // 회원가입은 성공, Firestore 저장 실패는 무시
      });

      return Success(user);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty) {
        return const Error(ValidationFailure('이메일은 필수입니다'));
      }
      if (password.trim().isEmpty) {
        return const Error(ValidationFailure('비밀번호는 필수입니다'));
      }

      // Firebase Auth 로그인
      final uid = await _dataSource.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Firestore에서 사용자 정보 조회
      final userDto = await _dataSource.getUser(uid);
      final user = userDto.toModel();

      if (user == null) {
        // Firestore에 정보가 없으면 기본 모델 생성
        final now = DateTime.now();
        return Success(UserModel(
          uid: uid,
          email: email.trim().toLowerCase(),
          isEmailVerified: false,
          createdAt: now,
          updatedAt: now,
        ));
      }

      return Success(user);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      final uid = await _dataSource.signInWithGoogle();

      // Firestore에서 사용자 정보 조회
      final userDto = await _dataSource.getUser(uid);
      final user = userDto.toModel();

      if (user != null) {
        return Success(user);
      }

      // Firestore에 정보가 없으면 Firebase Auth에서 정보 가져와 저장
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final now = DateTime.now();
      final newUser = UserModel(
        uid: uid,
        email: firebaseUser?.email ?? '',
        displayName: firebaseUser?.displayName,
        isEmailVerified: firebaseUser?.emailVerified ?? false,
        createdAt: now,
        updatedAt: now,
      );

      // Firestore에 사용자 정보 저장
      _dataSource.saveUser(newUser.toDto()).catchError((_) {});

      return Success(newUser);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<UserModel>> signInWithApple() async {
    try {
      final uid = await _dataSource.signInWithApple();

      final userDto = await _dataSource.getUser(uid);
      final user = userDto.toModel();

      if (user != null) {
        return Success(user);
      }

      final firebaseUser = FirebaseAuth.instance.currentUser;
      final now = DateTime.now();
      final newUser = UserModel(
        uid: uid,
        email: firebaseUser?.email ?? '',
        displayName: firebaseUser?.displayName,
        isEmailVerified: firebaseUser?.emailVerified ?? false,
        createdAt: now,
        updatedAt: now,
      );

      _dataSource.saveUser(newUser.toDto()).catchError((_) {});

      return Success(newUser);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      if (email.trim().isEmpty) {
        return const Error(ValidationFailure('이메일은 필수입니다'));
      }

      await _dataSource.sendPasswordResetEmail(email.trim());
      return const Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final currentUid = _dataSource.currentUserId;
      if (currentUid == null) {
        return const Error(UnauthorizedFailure('로그인이 필요합니다'));
      }

      final userDto = await _dataSource.getUser(currentUid);
      final user = userDto.toModel();

      if (user == null) {
        return const Error(ServerFailure('사용자 정보를 변환할 수 없습니다'));
      }

      return Success(user);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _dataSource.authStateChanges.asyncMap((uid) async {
      if (uid == null) return null;
      try {
        final userDto = await _dataSource.getUser(uid);
        return userDto.toModel();
      } catch (_) {
        return null;
      }
    });
  }

  @override
  bool get isSignedIn => _dataSource.isSignedIn;

  @override
  String? get currentUserId => _dataSource.currentUserId;
}
