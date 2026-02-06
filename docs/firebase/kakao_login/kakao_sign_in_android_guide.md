# 카카오 로그인 + Firebase Custom Token 완전 구현 가이드

## 🎯 프로젝트 정보
- **프로젝트**: lifetime-ledger
- **Bundle ID**: com.lifetime_ledger_seonho.lifetime_ledger
- **Firebase Project ID**: lifetime-ledger
- **Project Number**: 572681652958
- **아키텍처**: Clean Architecture + MVVM + Provider + Freezed 3.0

## 📋 목차
1. [개요](#개요)
2. [핵심 이슈 및 해결 과정](#핵심-이슈-및-해결-과정)
3. [단계별 구현 가이드](#단계별-구현-가이드)
4. [주요 문제와 해결책](#주요-문제와-해결책)
5. [검증 체크리스트](#검증-체크리스트)
6. [다음 프로젝트 적용 프롬프트](#다음-프로젝트-적용-프롬프트)

## 개요

카카오 로그인과 Firebase Custom Token을 통합하는 완전한 솔루션입니다. OIDC 방식 대신 **Custom Token 방식**을 사용하여 더 안정적이고 효율적인 인증을 구현합니다.

### 핵심 특징
- ✅ 카카오 네이티브 로그인 (Chrome Custom Tabs 문제 해결)
- ✅ Firebase Custom Token 생성 및 인증
- ✅ Firestore 사용자 데이터 자동 저장
- ✅ FCM 토큰 관리
- ✅ Clean Architecture 패턴 적용

## 핵심 이슈 및 해결 과정

### 🚨 주요 해결된 문제

#### 1. Android 매니페스트 호환성 문제
**문제**: ClassNotFoundException 및 Android 12+ 호환성
```xml
<!-- ❌ 기존 (문제 있던 코드) -->
<activity android:name="com.kakao.sdk.auth.AuthCodeHandlerActivity" />

<!-- ✅ 해결 -->
<activity
    android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="kakao[KAKAO_APP_KEY]" android:host="oauth"/>
    </intent-filter>
</activity>
```

#### 2. Firebase Functions 권한 문제
**문제**: `iam.serviceAccounts.signBlob` permission denied
**원인**: Service Account Token Creator 역할 누락
**해결**: 올바른 서비스 계정에 권한 부여

#### 3. OIDC vs Custom Token 방식 선택
**결정**: Custom Token 방식 채택 (OIDC 제거)
**이유**:
- Chrome Custom Tabs 문제 해결
- 더 직접적인 Firebase 통합
- 권한 관리 용이성

## 단계별 구현 가이드

### Step 1: 카카오 개발자 설정

#### 1.1 카카오 앱 생성 및 설정
1. [Kakao Developers](https://developers.kakao.com) 접속
2. 앱 생성: `lifetime-ledger`
3. **OpenID Connect 활성화** ✅
4. 리다이렉트 URI 설정:
   ```
   https://lifetime-ledger.firebaseapp.com/__/auth/handler
   ```

#### 1.2 Android 플랫폼 등록
- 패키지명: `com.lifetime_ledger_seonho.lifetime_ledger`
- 마켓 URL: `market://details?id=com.lifetime_ledger_seonho.lifetime_ledger`
- 키 해시: `Vw7Dc6nP1F4hE1bUXbp9FKUjinM=`

### Step 2: Firebase Functions 구현

#### 2.1 Functions 코드 작성
```javascript
// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

// Firebase Admin 초기화 (ADC 방식)
admin.initializeApp();

/**
 * 카카오 로그인을 위한 Custom Token 생성 (HTTP 함수)
 */
exports.createKakaoCustomToken = functions.https.onRequest(async (req, res) => {
  // CORS 설정
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  const { kakaoAccessToken } = req.body;

  if (!kakaoAccessToken) {
    res.status(400).json({
      error: { code: "invalid-argument", message: "카카오 액세스 토큰이 필요합니다." }
    });
    return;
  }

  try {
    // 1. 카카오 API로 사용자 정보 검증
    const kakaoUser = await verifyKakaoAccessToken(kakaoAccessToken);

    // 2. Firebase Custom Token 생성
    const kakaoId = kakaoUser.id.toString();
    const additionalClaims = {
      provider: "kakao",
      kakao_id: kakaoId,
      email: kakaoUser.kakao_account?.email || `kakao_${kakaoId}@temp.local`,
      name: kakaoUser.kakao_account?.profile?.nickname || "카카오 사용자",
      picture: kakaoUser.kakao_account?.profile?.profile_image_url
    };

    const customToken = await admin.auth().createCustomToken(kakaoId, additionalClaims);

    // 3. Firestore에 사용자 정보 저장
    await saveKakaoUserToFirestore(kakaoId, kakaoUser);

    res.status(200).json({
      customToken: customToken,
      user: {
        uid: kakaoId,
        email: additionalClaims.email,
        displayName: additionalClaims.name,
        photoURL: additionalClaims.picture,
        provider: "kakao"
      }
    });

  } catch (error) {
    console.error("카카오 Custom Token 생성 실패:", error);
    res.status(500).json({
      error: { code: "internal", message: "카카오 로그인 처리 중 오류가 발생했습니다." }
    });
  }
});

// 카카오 액세스 토큰 검증
async function verifyKakaoAccessToken(accessToken) {
  const response = await axios.get("https://kapi.kakao.com/v2/user/me", {
    headers: {
      "Authorization": `Bearer ${accessToken}`,
      "Content-Type": "application/x-www-form-urlencoded;charset=utf-8"
    }
  });
  return response.data;
}

// Firestore 사용자 정보 저장
async function saveKakaoUserToFirestore(uid, kakaoUser) {
  const userRef = admin.firestore().collection("users").doc(uid);
  const existingDoc = await userRef.get();

  const email = kakaoUser.kakao_account?.email || `kakao_${uid}@temp.local`;
  const displayName = kakaoUser.kakao_account?.profile?.nickname || "카카오 사용자";
  const photoURL = kakaoUser.kakao_account?.profile?.profile_image_url;

  if (existingDoc.exists) {
    await userRef.update({
      lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
      ...(photoURL && { photoURL: photoURL }),
      ...(displayName && { displayName: displayName })
    });
  } else {
    await userRef.set({
      email: email,
      displayName: displayName,
      photoURL: photoURL || null,
      provider: "kakao",
      kakaoId: uid,
      isEmailVerified: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastLoginAt: admin.firestore.FieldValue.serverTimestamp()
    });
  }
}
```

#### 2.2 IAM 권한 설정 (중요!)
다음 서비스 계정들에 **Service Account Token Creator** 역할 부여:
- `572681652958-compute@developer.gserviceaccount.com` (Functions 빌드)
- `lifetime-ledger@appspot.gserviceaccount.com` (Functions 실행)
- `firebase-adminsdk-fbsvc@lifetime-ledger.iam.gserviceaccount.com` (Admin SDK)

### Step 3: Android 앱 설정

#### 3.1 AndroidManifest.xml 수정
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<activity
    android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="kakaoe59b708268251e6680e30d2b0898646f"
              android:host="oauth"/>
    </intent-filter>
</activity>
```

#### 3.2 의존성 추가
```yaml
# pubspec.yaml
dependencies:
  kakao_flutter_sdk_user: ^1.9.7+3
  firebase_auth: ^5.6.0
  firebase_core: ^3.14.0
  cloud_functions: ^5.5.2
  http: ^1.4.0
```

### Step 4: Flutter 코드 구현

#### 4.1 DataSource 구현
```dart
// lib/data/datasource/auth_firebase_datasource_impl.dart
Future<String> _signInWithKakaoNative() async {
  try {
    // 1. 카카오 토큰 받기
    final token = await UserApi.instance.loginWithKakaoTalk();

    // 2. HTTP Functions 호출해서 Custom Token 받기
    final response = await http.post(
      Uri.parse('https://us-central1-lifetime-ledger.cloudfunctions.net/createKakaoCustomToken'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'kakaoAccessToken': token.accessToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final responseData = json.decode(response.body);
    final customToken = responseData['customToken'] as String;

    // 3. Custom Token으로 Firebase 인증
    final credential = await _auth.signInWithCustomToken(customToken);
    return credential.user!.uid;

  } catch (e) {
    throw Exception('카카오 네이티브 로그인 실패: ${e.toString()}');
  }
}
```

## 주요 문제와 해결책

### ❌ 문제 1: iam.serviceAccounts.signBlob permission denied

**원인**: Functions 실행 서비스 계정에 Token Creator 권한 없음

**해결책**:
1. Google Cloud Console → IAM 접속
2. `lifetime-ledger@appspot.gserviceaccount.com` 찾기
3. "Service Account Token Creator" 역할 추가
4. Functions 재배포:
   ```bash
   firebase functions:delete createKakaoCustomToken --force
   firebase deploy --only functions:createKakaoCustomToken
   ```

### ❌ 문제 2: Chrome Custom Tabs 열림 현상

**원인**: OIDC 방식 사용 시 웹 브라우저 리다이렉트

**해결책**:
1. Firebase Console에서 OIDC 프로바이더 사용 중지
2. Custom Token 방식으로 완전 전환
3. 카카오에서는 OpenID Connect 유지 (ID 토큰 필요)

### ❌ 문제 3: Android 12+ ClassNotFoundException

**해결책**: 올바른 Activity 클래스명 사용
```xml
<!-- ✅ 올바른 설정 -->
android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
```

## 검증 체크리스트

### 초기 설정
- [ ] 카카오 개발자 앱 생성 및 OpenID Connect 활성화
- [ ] Android 플랫폼 등록 (패키지명, 키해시)
- [ ] Firebase Functions IAM 권한 설정
- [ ] AndroidManifest.xml 수정

### 구현 검증
- [ ] Custom Token 생성 성공 로그 확인
- [ ] Firebase Auth 로그인 성공
- [ ] Firestore 사용자 데이터 저장 확인
- [ ] FCM 토큰 등록 확인

### 성공 로그 예시
```
flutter: ✅ 카카오 계정으로 로그인 성공
flutter: 🔐 Firebase Functions를 통한 Custom Token 생성 요청
flutter: ✅ Custom Token 생성 성공
flutter: ✅ Firebase Custom Token 로그인 성공: 4451927290
flutter: 📧 사용자 이메일: kakao_4451927290@temp.local
flutter: ✅ Repository: 카카오 로그인 완료
```

## 다음 프로젝트 적용 프롬프트

### 🤖 Claude Code 지시사항

다음 프롬프트를 사용하여 새 프로젝트에서 카카오 로그인을 빠르게 구현하세요:

```
카카오 로그인 + Firebase Custom Token 통합을 구현해줘.

프로젝트 정보:
- Bundle ID: [YOUR_BUNDLE_ID]
- Firebase Project ID: [YOUR_FIREBASE_PROJECT_ID]
- 아키텍처: Clean Architecture + MVVM + Provider + Freezed

구현 요구사항:
1. Custom Token 방식 사용 (OIDC 사용 안 함)
2. HTTP Functions로 구현
3. Android 12+ 호환성 확보
4. Chrome Custom Tabs 문제 방지

참조 문서: /docs/firebase/kakao_login/kakao_sign_in_complete_guide.md

주요 확인사항:
- AndroidManifest에 AuthCodeCustomTabsActivity 사용
- IAM에서 Service Account Token Creator 역할 확인
- Functions는 ADC 방식으로 초기화
- 카카오 OpenID Connect는 활성화 유지

단계별로 진행하고 각 단계별 검증 후 다음 단계로 진행해줘.
```

### 🔧 사용자 수동 작업 항목

다음 항목들은 Claude Code가 자동화할 수 없으므로 사용자가 직접 수행:

1. **카카오 개발자 콘솔 설정**
   - 앱 생성 및 OpenID Connect 활성화
   - Android 플랫폼 등록

2. **Google Cloud Console IAM 설정**
   - Service Account Token Creator 역할 부여

3. **Firebase Functions 배포**
   ```bash
   firebase deploy --only functions:createKakaoCustomToken
   ```

## 추가 참고사항

### Firestore 인덱스 생성
사용자 생성 후 내역 조회 시 인덱스 필요:
- 컬렉션: `histories`
- 필드: `userId` (오름차순), `createdAt` (내림차순)

### 보안 고려사항
- 카카오 앱 키는 코드에 노출되지 않도록 환경변수 사용
- Firebase Functions는 HTTPS Only
- Custom Token에는 민감한 정보 포함 금지

---

이 가이드를 통해 카카오 로그인을 성공적으로 구현할 수 있습니다.
다음 프로젝트에서는 위의 프롬프트를 사용하여 빠르게 적용하세요.