# 🔥 Firebase Integration Guide

> Complete Firebase integration with Clean Architecture + MVVM + Provider pattern

## 🎯 개요

**Clean Architecture + MVVM + Provider** 구조에서 Firebase를 백엔드 플랫폼으로 사용합니다.

- **Firebase Authentication**: 사용자 인증 및 관리
- **Cloud Firestore**: 실시간 데이터베이스
- **Firebase Storage**: 파일 업로드 저장소
- **Cloud Functions**: 서버리스 백엔드 로직

## 🚀 빠른 설정

### 사전 요구사항
- Firebase CLI 설치 (`npm install -g firebase-tools`)
- FlutterFire CLI 설치 (`dart pub global activate flutterfire_cli`)
- Firebase 프로젝트 생성

### 초기 설정
```bash
# 1. Flutter용 Firebase 구성
flutterfire configure

# 2. 의존성 설치
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage

# 3. Firebase 콘솔에서 서비스 활성화
# - Authentication (이메일/비밀번호, Google, Apple, Kakao)
# - Firestore Database
# - Storage
# - Functions (선택사항)
```

## 🏗️ Clean Architecture에서의 Firebase

### 계층별 Firebase 통합

```
🎨 Presentation Layer (UI)
├── ViewModel (ChangeNotifier)      → Firebase 인증 상태 구독
├── State (Freezed 3.0)            → Firebase 데이터 상태 관리
└── View                           → Firebase UI 통합

🏛️ Domain Layer (비즈니스 로직)
├── UseCase                         → 순수 비즈니스 로직 (Firebase 의존성 없음)
├── Repository Interface            → Firebase 구현 세부사항 숨김
└── Model (Entity)                  → Firebase 독립적인 도메인 객체

📊 Data Layer (데이터)
├── Repository Implementation       → Firebase Exception → Result<T> 변환
├── DataSource (Firebase)           → Firebase SDK 직접 사용
├── DTO                            → fromFirestore(), toFirestore() 메서드
└── Mapper (Extension)              → DTO ↔ Entity 변환
```

### Firebase 서비스 통합 현황

| 서비스 | 목적 | 계층 | 구현체 |
|---------|---------|--------|----------------|
| **Authentication** | 사용자 인증 관리 | Data | AuthFirebaseDataSourceImpl |
| **Firestore** | 실시간 데이터베이스 | Data | HistoryFirebaseDataSourceImpl |
| **Storage** | 파일 업로드 저장소 | Data | StorageFirebaseDataSourceImpl |
| **Functions** | 서버리스 백엔드 로직 | Data | Cloud Functions triggers |
| **Crashlytics** | 오류 추적 | Infrastructure | Global error handler |

---

## 🔐 Firebase Authentication 통합

```dart
abstract class AuthDataSource {
  Future<UserDto?> getCurrentUser();
  Future<UserDto> signInWithEmailAndPassword(String email, String password);
  Future<UserDto> signInWithGoogle();
  Future<void> signOut();
  Stream<UserDto?> get authStateChanges;
}

class AuthFirebaseDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserDto> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!.toDto();
    } on FirebaseAuthException catch (e) {
      throw FirebaseErrorMapper.mapFirebaseAuthException(e);
    }
  }

  @override
  Stream<UserDto?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) => user?.toDto());
  }
}
```

### Firebase User 확장

```dart
// data/mapper/user_mapper.dart
extension FirebaseUserMapper on firebase_auth.User {
  UserDto toDto() {
    return UserDto(
      id: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      emailVerified: emailVerified,
      createdAt: metadata.creationTime,
      lastSignInAt: metadata.lastSignInTime,
    );
  }
}
```

---

## 📊 Cloud Firestore 통합

### Firestore DataSource 구현

```dart
// data/datasource/[feature]_firebase_datasource.dart
abstract class [Feature]DataSource {
  Future<List<[Model]Dto>> get[Model]List();
  Future<[Model]Dto> get[Model]ById(String id);
  Future<void> add[Model]([Model]Dto model);
  Future<void> update[Model]([Model]Dto model);
  Future<void> delete[Model](String id);

  // 필요한 경우에만 사용 (Firestore 읽기 비용 발생)
  Stream<List<[Model]Dto>> watch[Model]List();
}

class [Feature]FirebaseDataSourceImpl implements [Feature]DataSource {
  final FirebaseFirestore _firestore;

  [Feature]FirebaseDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<[Model]Dto>> get[Model]List() async {
    try {
      final querySnapshot = await _firestore
          .collection('[collection]')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => [Model]Dto.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseErrorMapper.mapFirestoreException(e);
    }
  }

  @override
  Future<void> add[Model]([Model]Dto model) async {
    try {
      await _firestore
          .collection('[collection]')
          .doc(model.id)
          .set(model.toFirestore());
    } catch (e) {
      throw ServerException('거래 내역 저장 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Stream<List<[Model]Dto>> watch[Model]List() {
    // ⚠️ 주의: 실시간 리스너는 읽기 비용 발생 - 필요한 경우에만 사용
    return _firestore
        .collection('[collection]')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => [Model]Dto.fromFirestore(doc))
            .toList());
  }
}
```

### DTO와 Mapper 패턴 (Clean Architecture)

```dart
// 🔥 data/datasource/[feature]_firebase_datasource.dart - Firebase 변환 내재화
class [Feature]FirebaseDataSourceImpl implements [Feature]DataSource {
  // Firestore → DTO 변환 (내부 메서드)
  [Model]Dto _documentToDto(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return [Model]Dto(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(), // ← Firebase 변환
    );
  }

  // DTO → Firestore 변환 (내부 메서드)
  Map<String, dynamic> _dtoToDocument([Model]Dto dto) {
    return {
      'userId': dto.userId,
      'title': dto.title,
      'createdAt': dto.createdAt != null
          ? Timestamp.fromDate(dto.createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  @override
  Future<List<[Model]Dto>> get[Model]List() async {
    final snapshot = await _firestore
        .collection('[collection]')
        .get();

    return snapshot.docs.map(_documentToDto).toList();
  }

  @override
  Future<void> add[Model]([Model]Dto dto) async {
    await _firestore
        .collection('[collection]')
        .add(_dtoToDocument(dto));
  }
}
```

---

## ⚡ Cloud Functions 통합

### 서버리스 백엔드 로직 패턴

```typescript
// functions/src/[feature]/index.ts
export const on[Model]Change = functions.firestore
  .document('[collection]/{docId}')
  .onWrite(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // 비즈니스 로직 처리
    await process[Feature]Logic(before, after);
  });
```

### Flutter에서 Functions 호출

```dart
// data/datasource/[feature]_functions_datasource.dart
class [Feature]FunctionsDataSource {
  final FirebaseFunctions _functions;

  Future<[Result]Dto> call[Feature]Function(String param) async {
    try {
      final callable = _functions.httpsCallable('[functionName]');
      final result = await callable.call({'param': param});
      return [Result]Dto.fromJson(result.data);
    } catch (e) {
      throw ServerException('[기능] 처리 중 오류: $e');
    }
  }
}
```

---

## 📁 Firebase Storage 통합

### Storage DataSource 패턴

```dart
// data/datasource/[feature]_storage_datasource.dart
abstract class [Feature]StorageDataSource {
  Future<String> upload[Asset](String userId, String fileName, Uint8List data);
  Future<void> delete[Asset](String url);
  Future<String> getDownloadUrl(String path);
}

class [Feature]StorageDataSourceImpl implements [Feature]StorageDataSource {
  final FirebaseStorage _storage;

  @override
  Future<String> upload[Asset](String userId, String fileName, Uint8List data) async {
    try {
      final ref = _storage.ref().child('[folder]/$userId/$fileName');
      await ref.putData(data);
      return await ref.getDownloadURL();
    } catch (e) {
      throw ServerException('[파일] 업로드 실패: $e');
    }
  }

  @override
  Future<void> delete[Asset](String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      throw ServerException('[파일] 삭제 실패: $e');
    }
  }
}
```

---

## 🔧 Firebase 초기화

### main.dart 설정

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
```

### Provider 계층별 설정

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Firebase 인스턴스
        Provider(create: (_) => FirebaseAuth.instance),
        Provider(create: (_) => FirebaseFirestore.instance),
        Provider(create: (_) => FirebaseStorage.instance),

        // 2. DataSource 계층
        Provider<[Feature]DataSource>(
          create: (context) => [Feature]FirebaseDataSourceImpl(
            firestore: context.read<FirebaseFirestore>(),
          ),
        ),

        // 3. Repository 계층
        Provider<[Feature]Repository>(
          create: (context) => [Feature]RepositoryImpl(
            dataSource: context.read<[Feature]DataSource>(),
          ),
        ),

        // 4. UseCase 계층
        Provider<[Action]UseCase>(
          create: (context) => [Action]UseCase(
            repository: context.read<[Feature]Repository>(),
          ),
        ),
      ],
      child: MaterialApp(home: AuthWrapper()),
    );
  }
}
```

### 인증 상태 관리

```dart
// ui/auth_wrapper.dart
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const MainScreen();   // 로그인됨
        }
        return const LoginScreen();    // 로그인 안됨
      },
    );
  }
}
```

---

## 🔧 환경 설정

### 개발/운영 환경 분리

```dart
// core/config/firebase_config.dart
class FirebaseConfig {
  static void configure() {
    if (kDebugMode) {
      // 개발: Emulator 사용
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    }
  }
}
```

## 🛡️ 보안 규칙

### Firestore 보안 규칙

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자는 자신의 데이터만 접근 가능
    match /[collection]/{docId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### Storage 보안 규칙

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // 사용자별 폴더 접근 제한
    match /[folder]/{userId}/{fileName} {
      allow read, write: if request.auth != null
        && request.auth.uid == userId;
    }
  }
}
```

## ⚡ 성능 최적화

### withConverter로 타입 안전성 (권장)

```dart
// ✅ 타입 안전한 Firestore 참조
final userRef = FirebaseFirestore.instance
    .collection('users')
    .withConverter<UserDto>(
      fromFirestore: (snapshot, _) => UserDto.fromFirestore(snapshot),
      toFirestore: (user, _) => user.toFirestore(),
    );

// 사용 시 자동 타입 변환
final userDoc = await userRef.doc(userId).get();
final UserDto? user = userDoc.data();  // 타입 안전

// 저장 시에도 타입 체크
await userRef.doc(userId).set(userDto);  // UserDto만 허용
```

### DataSource에서 withConverter 활용

```dart
class [Feature]FirebaseDataSourceImpl implements [Feature]DataSource {
  final FirebaseFirestore _firestore;

  // withConverter로 타입 안전한 참조 생성
  late final CollectionReference<[Model]Dto> _collection;

  [Feature]FirebaseDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore {
    _collection = _firestore.collection('[collection]').withConverter<[Model]Dto>(
      fromFirestore: (snapshot, _) => [Model]Dto.fromFirestore(snapshot),
      toFirestore: (dto, _) => dto.toFirestore(),
    );
  }

  @override
  Future<List<[Model]Dto>> get[Model]List() async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();  // 타입 안전
  }
}
```

### Firestore 쿼리 최적화

```dart
// 💡 항상 limit 사용, 인덱스 필드로 정렬
final query = firestore
    .collection('[collection]')
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .limit(20);  // ← 필수: 읽기 비용 제한
```

### Stream 리스너 관리

```dart
class [Feature]ViewModel extends ChangeNotifier {
  StreamSubscription? _subscription;

  void startListening() {
    _subscription?.cancel();  // 기존 리스너 정리
    _subscription = firestore
        .collection('[collection]')
        .snapshots()
        .listen((data) { /* 처리 */ });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

## 🚨 Firebase 예외 처리

### 예외 매핑 패턴

```dart
// data/mapper/firebase_error_mapper.dart
class FirebaseErrorMapper {
  static Failure mapAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => const AuthFailure('사용자 없음'),
      'wrong-password' => const AuthFailure('비밀번호 오류'),
      'email-already-in-use' => const AuthFailure('중복 이메일'),
      _ => AuthFailure('Auth 오류: ${e.code}'),
    };
  }

  static Failure mapFirestoreException(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' => const FirebaseFailure('권한 없음'),
      'not-found' => const FirebaseFailure('데이터 없음'),
      _ => FirebaseFailure('Firestore 오류: ${e.code}'),
    };
  }
}
```

## 🗂️ Firestore 데이터베이스 구조

### 커렉션 구조

```text
📁 Firestore
├── [collection]/              # 기본 커렉션
│   └── {documentId}          # 문서 ID
│       ├── userId: string    # 사용자 ID (보안)
│       ├── title: string
│       ├── createdAt: Timestamp
│       └── updatedAt: Timestamp
```

---

## 📦 참고 자료

- [Firebase Console](https://console.firebase.google.com)
- [FlutterFire 공식 문서](https://firebase.google.com/docs/flutter/setup)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)

---