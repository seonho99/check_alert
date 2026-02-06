# 🔥 Firebase FCM 푸시 알림 가이드

## 🎯 개요

Flutter 앱에서 Firebase Cloud Messaging (FCM)을 사용한 실시간 푸시 알림 시스템 구현 가이드입니다.

### 시스템 구조
```
Flutter App → Firestore 트리거 → Firebase Functions → FCM → 사용자 기기
```

### 필수 Dependencies
```yaml
dependencies:
  firebase_messaging: ^15.1.7
  flutter_local_notifications: ^19.0.0
  cloud_functions: ^5.0.0
```

---

## 🎯 1. Flutter FCM Service 구현

### 실제 구현 파일 위치
- **메인 구현**: `lib/core/services/fcm_service.dart` (1187줄)
- **iOS 최적화 버전**: `lib/core/services/fcm_service_ios_safe.dart` (489줄)

### 핵심 특징
- **두 가지 서비스 클래스**: `FCMService` (일반), `FCMServiceIOSSafe` (iOS 최적화)
- **iOS/Android 플랫폼별 최적화** 처리
- **백그라운드 메시지 안전 처리**
- **FCM 토큰 자동 관리** 및 Firestore 동기화
- **토큰 클립보드 복사** 및 수동 재생성 기능
- **iOS 키보드 상태 모니터링** (iOS 앱 멈춤 방지)

### 주요 메서드
```dart
// FCM 토큰 클립보드 복사 (디버깅용)
await FCMService().copyTokenToClipboard();

// FCM 토큰 수동 재생성 (문제 해결시)
final newToken = await FCMService().getTokenManually();

// Context 설정 (네비게이션용)
FCMService().setContext(context);

// iOS 안전 모드 초기화
await FCMServiceIOSSafe().initializeIOSSafe();
```

### 초기화 단계
1. **iOS 포그라운드 알림 옵션 설정** (필수)
2. **알림 권한 요청**
3. **FCM 토큰 생성 및 Firestore 저장**
4. **메시지 리스너 설정**
5. **Context 설정** (네비게이션용)

---

## 🔧 5. main.dart에서 FCM 초기화

### 기본 초기화 (일반 앱)
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // FCM 서비스 초기화
  await FCMService().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // FCM에 context 설정 (네비게이션용)
    FCMService().setContext(context);

    return MaterialApp(
      // 앱 설정...
    );
  }
}
```

### iOS 안전 모드 초기화 (iOS 앱 멈춤 방지)
```dart
import 'core/services/fcm_service_ios_safe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // iOS 안전 모드로 초기화
  if (Platform.isIOS) {
    await FCMServiceIOSSafe().initializeIOSSafe();
  } else {
    await FCMService().initialize();
  }

  runApp(MyApp());
}
```

### 디버깅용 설정 화면 추가
```dart
// 설정 화면에서 FCM 토큰 확인/복사
ElevatedButton(
  onPressed: () async {
    await FCMService().copyTokenToClipboard();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('FCM 토큰이 클립보드에 복사되었습니다')),
    );
  },
  child: Text('FCM 토큰 복사'),
),

// FCM 토큰 재생성 (문제 해결시)
ElevatedButton(
  onPressed: () async {
    final newToken = await FCMService().getTokenManually();
    print('새 토큰: $newToken');
  },
  child: Text('FCM 토큰 재생성'),
)
```

---

## 🚀 2. Firebase Functions 구현

### 핵심 기능
- **Firestore 트리거**: `histories` 컬렉션에 지출 추가 시 자동 실행
- **예산 모니터링**: 월별 예산 대비 사용률 계산 (60%, 80%, 100% 기준)
- **FCM 알림 전송**: 조건에 따른 자동 푸시 알림

### 실제 구현 파일
- `functions/index.js`: `onExpenseAdded` 함수 구현
- 알림 임계값: 60% (주의), 80% (위험), 100% (초과)

### 배포 명령어
```bash
firebase deploy --only functions  # Functions 배포
firebase functions:log --follow   # 실시간 로그 확인
```

---

## 📊 3. Firestore 데이터 구조

### users 컬렉션
```javascript
{
  "users": {
    "{userId}": {
      "fcmToken": "string",
      "platform": "ios|android",
      "deviceId": "string",
      "lastUpdated": "timestamp",
      // ... 기타 사용자 정보
    }
  }
}
```

### budgets 컬렉션
```javascript
{
  "budgets": {
    "{documentId}": {
      "userId": "string",
      "year": 2025,
      "month": 8,
      "monthlyBudget": 150000,
      "categoryBudgets": {
        "식비": 50000,
        "교통": 50000,
        "카페": 50000
      },
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
  }
}
```

### histories 컬렉션
```javascript
{
  "histories": {
    "{historyId}": {
      "userId": "string",
      "title": "string",
      "amount": 25000,
      "type": "expense|income",
      "categoryId": "string",
      "date": "timestamp",
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
  }
}
```

---

## 🔧 4. Firestore 인덱스 설정

### 필수 복합 인덱스

**histories 컬렉션 인덱스:**
- Collection: `histories`
- Fields: 
  - `type` (Ascending)
  - `userId` (Ascending)
  - `date` (Ascending)

**budgets 컬렉션 인덱스:**
- Collection: `budgets`
- Fields:
  - `userId` (Ascending)
  - `year` (Ascending)
  - `month` (Ascending)

### 인덱스 생성 방법

1. **자동 생성**: Functions 실행 시 로그에 나오는 인덱스 링크 클릭
2. **수동 생성**: Firebase Console > Firestore > 색인 탭에서 생성
3. **firestore.indexes.json 파일**로 관리

---

## 📱 5. main.dart에서 초기화

```dart
import 'package:firebase_core/firebase_core.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM 서비스 초기화
  await FCMService().initialize();

  runApp(const MyApp());
}
```

---

## 🧪 6. 테스트 및 디버깅

### 핵심 테스트 포인트
1. **FCM 토큰 생성 확인** - 앱 실행 후 콘솔 로그 확인
2. **Firebase Console 테스트** - 수동 메시지 발송으로 기본 동작 확인
3. **앱 상태별 테스트** - 포그라운드/백그라운드/종료 상태에서 알림 확인
4. **자동 알림 테스트** - 지출 추가 시 예산 알림 자동 발송

### 주요 문제 해결
- **iOS 포그라운드 알림 미표시**: `setForegroundNotificationPresentationOptions` 설정 필수
- **실기기 전용**: 시뮬레이터에서는 FCM 정상 동작 불가

---

## 🚨 7. 문제 해결 가이드

### 실기기 관련 문제 해결

1. **🍎 iOS 포그라운드 알림이 표시되지 않는 경우** (핵심 해결책)
   ```dart
   // FCM 초기화 시 반드시 추가
   await _messaging.setForegroundNotificationPresentationOptions(
     alert: true,
     badge: true, 
     sound: true,
   );
   ```
   - **원인**: iOS는 기본적으로 포그라운드에서 알림을 표시하지 않음
   - **해결**: `setForegroundNotificationPresentationOptions` 설정 필수

2. **🔄 FCM 토큰이 계속 변경되는 경우**
   - iOS: 앱 재설치, iOS 업데이트 시 토큰 변경
   - 해결: `onTokenRefresh` 리스너로 자동 업데이트
   ```dart
   _messaging.onTokenRefresh.listen((newToken) async {
     await _saveTokenToFirestore(userId, newToken);
   });
   ```

3. **📱 실기기에서만 알림이 안 오는 경우**
   - 시뮬레이터는 FCM을 지원하지 않음 (실기기 필수)
   - iOS: 개발자 프로비저닝 프로필에 Push Notifications 권한 확인
   - Android: Google Play Services 설치 확인

### 일반적인 문제들

1. **FCM 토큰이 null인 경우**
   - 권한 확인: 알림 권한이 승인되었는지 확인
   - iOS: APNs 토큰 대기 시간 증가
   - 토큰 재생성: `getTokenManually()` 호출

2. **Functions가 트리거되지 않는 경우**
   - Functions 배포 상태 확인: `firebase functions:list`
   - Firestore 데이터 저장 확인
   - 트리거 경로 확인: `histories/{historyId}`

3. **인덱스 오류**
   - 로그의 인덱스 생성 링크 클릭
   - 인덱스 생성 완료까지 몇 분 대기
   - 복합 쿼리 최적화

4. **알림이 오지 않는 경우**
   - FCM 토큰 Firestore 저장 확인
   - 예산 데이터 존재 여부 확인
   - 월별 예산 > 0 확인
   - 사용률 임계값 (60%, 80%, 100%) 확인

### 디버깅 체크리스트

#### 📋 기본 설정
- [ ] Firebase 프로젝트 설정 완료
- [ ] FCM 토큰 정상 생성 및 저장
- [ ] Functions 정상 배포
- [ ] Firestore 인덱스 생성 완료
- [ ] 예산 데이터 올바른 형식으로 저장
- [ ] 지출 데이터 histories 컬렉션에 저장
- [ ] 알림 권한 승인

#### 📱 실기기 필수 확인 사항
- [ ] **iOS 포그라운드 알림 옵션 설정** (`setForegroundNotificationPresentationOptions`)
- [ ] **실제 기기에서 테스트** (시뮬레이터 불가)
- [ ] **APNs 토큰 정상 생성** (iOS)
- [ ] **Google Play Services 설치** (Android)
- [ ] **Push Notifications Capability 활성화** (iOS Xcode)
- [ ] **올바른 Bundle ID 설정** (Firebase Console과 일치)

---

## 📝 8. 새 프로젝트 적용 체크리스트

### 1단계: 환경 설정
- [ ] Firebase 프로젝트 생성
- [ ] Flutter 프로젝트에 Firebase 연동
- [ ] FCM 관련 패키지 설치
- [ ] iOS/Android 설정 (푸시 알림 권한)

### 2단계: 코드 구현
- [ ] FCMService 클래스 구현
- [ ] Firebase Functions 작성
- [ ] Firestore 데이터 구조 설계
- [ ] main.dart에서 FCM 초기화

### 3단계: 배포 및 테스트
- [ ] Functions 배포
- [ ] Firestore 인덱스 생성
- [ ] FCM 토큰 확인
- [ ] 알림 테스트

### 4단계: 최적화
- [ ] 알림 임계값 조정
- [ ] 로그 모니터링 설정
- [ ] 에러 핸들링 강화
- [ ] 성능 최적화

---

## 🔗 9. 참고 자료

- [Firebase Cloud Messaging 공식 문서](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging 플러그인](https://pub.dev/packages/firebase_messaging)
- [Firebase Functions 가이드](https://firebase.google.com/docs/functions)
- [Firestore 보안 규칙](https://firebase.google.com/docs/firestore/security/get-started)

---

**💡 이 가이드는 lifetime_ledger 프로젝트에서 실제 구현되고 테스트된 내용을 바탕으로 작성되었습니다. 새 프로젝트에 적용할 때 프로젝트 특성에 맞게 수정하여 사용하세요.**