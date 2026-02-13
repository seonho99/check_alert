# Firestore 컬렉션/서브컬렉션 구조

> **참조**: [docs/logic/](../logic/) 가이드 + [docs/firebase/](../firebase/) 가이드

---

## 1. 전체 구조

```
users/{userId}                          # 사용자 문서
  ├── tasks/{taskId}                    # 체크 항목 (서브컬렉션)
  └── checkRecords/{recordId}           # 체크 기록 (서브컬렉션)
```

---

## 2. 컬렉션별 상세

### 2.1 `users/{userId}` (사용자 문서)

| 필드 | 타입 | 설명 |
|------|------|------|
| `uid` | string | 사용자 고유 ID (Firebase Auth UID) |
| `email` | string | 이메일 주소 |
| `displayName` | string? | 표시 이름 |
| `isEmailVerified` | bool | 이메일 검증 상태 |
| `createdAt` | timestamp | 계정 생성 일시 |
| `updatedAt` | timestamp | 최종 수정 일시 |

### 2.2 `users/{userId}/tasks/{taskId}` (체크 항목)

| 필드 | 타입 | 설명 | 기본값 |
|------|------|------|--------|
| `userId` | string | 사용자 UID | 필수 |
| `name` | string | 항목 이름 | 필수 |
| `category` | string | 카테고리 | "" |
| `repeatType` | string | 반복 유형 ("weekly"/"monthly"/"once") | "weekly" |
| `repeatDays` | array\<int\> | 반복 요일 (1=월~7=일) — weekly용 | [1,2,3,4,5,6,7] |
| `repeatMonthDays` | array\<int\> | 반복 일자 (1~31) — monthly용 | [] |
| `specificDates` | array\<timestamp\> | 특정 날짜 목록 — once용 | [] |
| `reminderHour` | int | 알림 시간 (0-23) | 9 |
| `reminderMinute` | int | 알림 분 (0-59) | 0 |
| `isActive` | bool | 활성화 상태 | true |
| `sortOrder` | int | 정렬 순서 | 0 |
| `createdAt` | timestamp | 생성 일시 | serverTimestamp |
| `updatedAt` | timestamp | 수정 일시 | serverTimestamp |

### 2.3 `users/{userId}/checkRecords/{recordId}` (체크 기록)

| 필드 | 타입 | 설명 | 기본값 |
|------|------|------|--------|
| `userId` | string | 사용자 UID | 필수 |
| `taskId` | string | 체크 항목 ID | 필수 |
| `date` | timestamp | 체크 날짜 (시간 없음) | 필수 |
| `isCompleted` | bool | 완료 상태 | false |
| `completedAt` | timestamp? | 완료 시각 | null |
| `createdAt` | timestamp | 생성 일시 | serverTimestamp |
| `updatedAt` | timestamp | 수정 일시 | serverTimestamp |

---

## 3. 보안 규칙 (Firestore Security Rules)

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // 공통 헬퍼 함수
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // users/{userId} - 사용자 문서
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // tasks 서브컬렉션 - 본인 데이터만 접근
      match /tasks/{taskId} {
        allow read, write: if isOwner(userId);

        // 생성 시 필수 필드 검증
        allow create: if isOwner(userId)
          && request.resource.data.keys().hasAny(['name', 'userId'])
          && request.resource.data.userId == userId;

        // 수정 시 userId 변경 불가
        allow update: if isOwner(userId)
          && request.resource.data.userId == userId;
      }

      // checkRecords 서브컬렉션 - 본인 데이터만 접근
      match /checkRecords/{recordId} {
        allow read, write: if isOwner(userId);

        // 생성 시 필수 필드 검증
        allow create: if isOwner(userId)
          && request.resource.data.keys().hasAny(['taskId', 'date', 'userId'])
          && request.resource.data.userId == userId;

        // 수정 시 userId, taskId, date 변경 불가
        allow update: if isOwner(userId)
          && request.resource.data.userId == userId
          && request.resource.data.taskId == resource.data.taskId
          && request.resource.data.date == resource.data.date;
      }

    }

    // 그 외 모든 경로 차단
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 4. 필수 인덱스 (Composite Indexes)

### 4.1 checkRecords 인덱스

```
# 날짜별 체크 기록 조회 (getRecordsByDate)
컬렉션 그룹: checkRecords
필드: date ASC
```

```
# 특정 Task + 날짜 조회 (getRecord - toggleCheck용)
컬렉션 그룹: checkRecords
필드: taskId ASC, date ASC
```

```
# 월별 통계 조회 (getRecordsByMonth)
컬렉션 그룹: checkRecords
필드: date ASC
```

```
# 특정 Task + 기간별 조회 (getRecordsByTaskAndRange)
컬렉션 그룹: checkRecords
필드: taskId ASC, date ASC
```

### 4.2 tasks 인덱스

```
# 오늘 요일 + 정렬 조회 (getTasksByDay)
컬렉션 그룹: tasks
필드: isActive ASC, repeatDays ARRAY_CONTAINS, sortOrder ASC
```

```
# 전체 항목 정렬 조회 (getTasks)
컬렉션 그룹: tasks
필드: sortOrder ASC
```

### 4.3 `firestore.indexes.json`

```json
{
  "indexes": [
    {
      "collectionGroup": "checkRecords",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "taskId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "tasks",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "isActive", "order": "ASCENDING" },
        { "fieldPath": "sortOrder", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

---

## 5. 데이터 관계도

```
UserModel (users/{userId})
    │
    ├─── 1:N ───▶ TaskModel (users/{userId}/tasks/{taskId})
    │                  │
    │                  └─── 1:N ───▶ CheckRecordModel (users/{userId}/checkRecords/{recordId})
    │                                 (taskId로 연결, date로 유니크 구분)
```

### 핵심 쿼리 패턴

| 쿼리 | Firestore 경로 | 조건 |
|-------|----------------|------|
| 오늘 체크 항목 | `users/{uid}/tasks` | `isActive == true AND repeatDays contains weekday` |
| 오늘 체크 기록 | `users/{uid}/checkRecords` | `date >= today AND date < tomorrow` |
| 체크 토글 조회 | `users/{uid}/checkRecords` | `taskId == X AND date >= today AND date < tomorrow` |
| 월별 통계 | `users/{uid}/checkRecords` | `date >= monthStart AND date < nextMonthStart` |
| Task 기간 통계 | `users/{uid}/checkRecords` | `taskId == X AND date >= start AND date <= end` |

---

## 6. 서브컬렉션 사용 이유

| 장점 | 설명 |
|------|------|
| **보안 격리** | 사용자별 데이터를 완전 분리, 보안 규칙 간단 |
| **쿼리 성능** | 사용자 범위 내에서만 쿼리, 불필요한 인덱스 최소화 |
| **확장성** | 사용자 수 증가에 따른 성능 영향 최소화 |
| **비용 효율** | 사용자별 데이터만 읽기, 불필요한 도큐먼트 읽기 방지 |

---
