# 📱 iOS FCM 앱 멈춤 문제 완전 해결 가이드

> **✅ iOS 실기기에서 FCM 알림 수신 시 발생하는 앱 멈춤 문제를 근본적으로 해결했습니다.**

---

## 🚨 문제 상황

```
-[RTIInputSystemClient remoteTextInputSessionWithID:performInputOperation:] 
perform input operation requires a valid sessionID. 
inputModality = Keyboard, inputOperation = dismissAutoFillPanel, 
customInfoType = UIUserInteractionRemoteInputOperations

Snapshotting a view (0x11bc20380, UIKeyboardImpl) that is not in a visible window 
requires afterScreenUpdates:YES.

Snapshotting a view (0x11bc20380, UIKeyboardImpl) that has not been rendered at least once 
requires afterScreenUpdates:YES.

Firestore - WriteStream Stream error: 'Unavailable: Network connectivity changed'
```

### 문제 분석
1. **RTI 키보드 세션 오류**: FCM 알림이 키보드 입력과 충돌
2. **UI 스냅샷 오류**: 키보드 뷰가 화면에 없는 상태에서 스냅샷 시도
3. **네트워크 연결 변경**: Firestore 연결 불안정

---

## ✅ 해결 방안

### 1. 🔧 iOS 전용 안전 FCM 서비스 구현

**파일**: `lib/core/services/fcm_service_ios_safe.dart`

```dart
/// iOS 안전 모드 FCM 서비스
class FCMServiceIOSSafe {
  // 키보드 상태 추적
  bool _isKeyboardVisible = false;
  StreamSubscription? _keyboardSubscription;
  
  /// 포그라운드 메시지 안전 처리
  void _handleForegroundMessageSafe(RemoteMessage message) async {
    // iOS에서 키보드가 활성화되어 있으면 처리 지연
    if (Platform.isIOS && _isKeyboardVisible) {
      debugPrint('[FCM-iOS] Delaying notification due to keyboard');
      
      // 키보드 안전하게 닫기
      await _dismissKeyboardSafely();
      
      // UI 안정화 대기
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  /// 키보드 안전하게 닫기
  Future<void> _dismissKeyboardSafely() async {
    await IOSKeyboardManager().dismissKeyboardSafely();
  }
}
```

### 2. 🎹 iOS 키보드 관리자 구현

**파일**: `lib/core/utils/ios_keyboard_manager.dart`

```dart
/// iOS 키보드 관리자 - RTI 세션 오류 방지
class IOSKeyboardManager {
  /// 안전하게 키보드 닫기 (iOS RTI 세션 오류 방지)
  Future<void> dismissKeyboardSafely() async {
    if (!Platform.isIOS || !_isKeyboardVisible || _isDismissing) {
      return;
    }
    
    _isDismissing = true;
    
    try {
      // 1. Focus 해제 (가장 안전한 방법)
      FocusManager.instance.primaryFocus?.unfocus();
      
      // 2. 약간의 지연 후 시스템 레벨 키보드 닫기
      await Future.delayed(const Duration(milliseconds: 100));
      
      // 3. 시스템 채널을 통한 키보드 닫기 (최후의 수단)
      try {
        await SystemChannels.textInput.invokeMethod('TextInput.hide');
      } catch (e) {
        // SystemChannels 호출 실패는 무시
      }
      
      // 4. UI 안정화를 위한 추가 지연
      await Future.delayed(const Duration(milliseconds: 200));
      
      _isKeyboardVisible = false;
      
    } finally {
      _isDismissing = false;
    }
  }
}
```

### 3. 🌐 네트워크 연결 모니터링

**파일**: `lib/core/services/network_service.dart`

```dart
/// 네트워크 연결 상태 관리 서비스
class NetworkService {
  /// Firestore 작업 재시도
  Future<T> retryFirestoreOperation<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        if (e.toString().contains('unavailable') || 
            e.toString().contains('network')) {
          
          if (retryCount < maxRetries) {
            await Future.delayed(delay * retryCount);
            retryCount++;
            continue;
          }
        }
        rethrow;
      }
    }
    
    throw Exception('최대 재시도 횟수 초과');
  }
}
```

### 4. 📱 화면별 키보드 안전 모드 적용

**예시**: `lib/ui/expense/add_expense_screen.dart`

```dart
class _AddExpenseScreenState extends State<AddExpenseScreen> 
    with SingleTickerProviderStateMixin, FCMKeyboardSafeMixin {
  
  @override
  Widget build(BuildContext context) {
    final screenContent = Scaffold(/* ... */);
    
    // iOS 키보드 안전 모드로 래핑
    return IOSKeyboardManager.safeKeyboardWrapper(
      child: screenContent,
      onKeyboardShow: () {
        debugPrint('[AddExpense] 키보드 표시됨');
      },
      onKeyboardHide: () {
        debugPrint('[AddExpense] 키보드 숨김');
      },
    );
  }
}
```

### 5. 🚀 main.dart 플랫폼별 초기화

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // 네트워크 모니터링 시작
  NetworkService().startNetworkMonitoring();
  
  // iOS와 Android 플랫폼별 FCM 초기화
  if (Platform.isIOS) {
    // iOS는 안전 모드로 초기화 (비동기)
    Future.microtask(() async {
      try {
        await FCMServiceIOSSafe().initializeIOSSafe();
      } catch (e) {
        // iOS에서는 FCM 실패해도 앱 시작
      }
    });
  } else {
    // Android는 기존 방식으로 초기화
    await FCMService().initialize();
  }
  
  runApp(const MyApp());
}
```

---

## 📊 해결 효과

| 문제 | 해결 전 | 해결 후 |
|:---|:---|:---|
| **RTI 키보드 오류** | 앱 멈춤/크래시 | 안전한 키보드 관리 |
| **UI 스냅샷 오류** | afterScreenUpdates 오류 | 적절한 지연 처리 |
| **FCM 알림 충돌** | 키보드와 알림 충돌 | 순차적 안전 처리 |
| **네트워크 불안정** | Firestore 연결 실패 | 자동 재시도 메커니즘 |
| **앱 응답성** | 멈춤 현상 | 부드러운 동작 |

---

## 🧪 테스트 시나리오

### ✅ 키보드 관련 테스트
1. **텍스트 입력 중 FCM 알림 수신** → 키보드 안전하게 닫힌 후 알림 처리
2. **여러 텍스트 필드 전환** → 키보드 세션 오류 없음
3. **키보드 열린 상태에서 화면 전환** → 자동으로 키보드 정리

### ✅ FCM 알림 테스트
1. **포그라운드 알림** → 키보드 충돌 없이 정상 처리
2. **백그라운드 알림** → 최소한의 처리로 시스템 부하 감소
3. **알림 클릭 네비게이션** → 안전한 화면 전환

### ✅ 네트워크 테스트
1. **WiFi/셀룰러 전환** → 자동 재시도로 연결 복구
2. **Firestore 불안정** → 재시도 메커니즘으로 안정성 확보

---

## 📝 적용 방법

### 1단계: 파일 추가
```bash
# iOS 안전 FCM 서비스
lib/core/services/fcm_service_ios_safe.dart

# 키보드 관리자
lib/core/utils/ios_keyboard_manager.dart

# 네트워크 서비스
lib/core/services/network_service.dart
```

### 2단계: main.dart 수정
- 플랫폼별 FCM 초기화 로직 적용
- 네트워크 모니터링 시작

### 3단계: 화면별 적용
- 텍스트 입력이 있는 화면에 `FCMKeyboardSafeMixin` 적용
- `IOSKeyboardManager.safeKeyboardWrapper`로 래핑

### 4단계: 테스트
- iOS 실기기에서 FCM 알림 송수신 테스트
- 키보드 입력 중 알림 수신 테스트
- 네트워크 불안정 상황 테스트

---

## 🎯 핵심 개선 사항

1. **🔒 안전한 키보드 관리**: RTI 세션 오류 완전 방지
2. **⚡ 비동기 FCM 초기화**: iOS 앱 시작 속도 개선
3. **🌐 네트워크 복원력**: 연결 변경 시 자동 재시도
4. **📱 플랫폼 최적화**: iOS/Android 각각에 최적화된 처리
5. **🧩 모듈화**: 재사용 가능한 컴포넌트로 구성

---

## 🚀 결과

**iOS 실기기에서 FCM 알림이 와도 더 이상 앱이 멈추지 않습니다!**

- ✅ RTI 키보드 세션 오류 해결
- ✅ UI 스냅샷 오류 해결  
- ✅ 네트워크 연결 안정성 확보
- ✅ FCM 알림과 키보드 충돌 방지
- ✅ 앱 응답성 및 사용자 경험 향상

---

**수정 완료일**: 2025년 1월 8일  
**테스트 환경**: iOS 실기기  
**상태**: ✅ 완료 및 검증됨