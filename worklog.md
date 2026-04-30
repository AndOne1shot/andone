# andone 작업 로그

<!-- Claude가 세션 종료 시 자동으로 기록합니다 -->

## 2026-04-29

### 포트폴리오 README 작성

- `README.md` 전면 개편
  - 기획 배경 섹션 추가 ("Todo 미완료 문제 → 다마고치 동기부여")
  - 스크린샷 섹션 추가 (home, todo_detail_1/2, profile_1/2)
  - 기술적 구현 포인트 섹션 추가 (반복 Todo 시간 계산, 기분 수치 시스템, 로컬 알림, 라우팅 보호)
  - Firestore 구조 업데이트 (`lastMoodDecreaseDate`, `ownedItems`, `equippedItems`, `items/` 컬렉션 추가)
  - 프로젝트 구조 업데이트 (`item_model.dart`, `monster_model.dart`, `home_tab_view_model.dart` 반영)
  - 기술 스택에 Flutter 버전(3.35.4 / Dart 3.9.2), `flutter_local_notifications` 추가
  - 로드맵 업데이트 (완료 항목 체크, 꾸미기 시스템/기분 감소 완료 처리)
  - 설치 섹션을 GitHub Releases APK 배포 방식으로 변경

### 로컬 알림 버그 수정

**1. 타임존 버그 수정**
- `tz.UTC` → `tz.local` 로 변경
- `flutter_timezone: ^3.0.0` 패키지 추가
- `init()` 에서 기기 로컬 타임존 감지 후 `tz.setLocalLocation()` 설정

**2. 정확한 알람 권한 개선**
- `USE_EXACT_ALARM` 제거 → `SCHEDULE_EXACT_ALARM` 만 사용 (일반 앱 기준)
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` 권한 추가
- `canScheduleExactNotifications()` 체크 후 미허용 시 설정 화면 이동

**3. 삼성 갤럭시 배터리 최적화 대응**
- `AndroidScheduleMode.exactAllowWhileIdle` → `AndroidScheduleMode.alarmClock` 으로 변경
- `MainActivity.kt` 에 MethodChannel 추가 — 배터리 최적화 해제 설정 화면 직접 이동
- `notification_service.dart` 에 `_requestIgnoreBatteryOptimizations()` 추가

**4. ProGuard 설정 추가 (핵심 수정)**
- release APK에서 R8이 `flutter_local_notifications` 클래스를 제거하여 알림이 동작하지 않던 문제 해결
- `android/app/proguard-rules.pro` 생성 (`com.dexterous.**`, Gson 관련 keep 규칙)
- `build.gradle.kts` release 빌드에 `isMinifyEnabled = true` + proguard 파일 적용

### APK 빌드 및 배포

- GitHub Releases 배포용 release APK 빌드 완료
- `build/app/outputs/flutter-apk/app-release.apk`

---

## 2026-04-28

### 꾸미기 시스템 - 악세서리 표시 개선

**1. 캔버스 크기 통일 (96x128)**
- 캐릭터와 악세서리 스프라이트를 동일한 캔버스 크기(96x128)로 통일하는 방식 도입
- 위쪽 32px → 악세서리(모자 등) 영역 / 아래쪽 96px → 캐릭터 영역
- Flutter Stack으로 겹치기만 해도 위치가 자동으로 맞는 구조

**2. ItemModel에 thumbnailPath 필드 추가** (`lib/model/item_model.dart`)
- 상점/꾸미기 목록용 썸네일 이미지 경로 필드 추가
- `displayPath` getter 추가 — 썸네일 있으면 썸네일, 없으면 assetPath 반환
- Firestore `thumbnailPath` 필드로 관리 (없는 아이템은 자동 fallback)

**3. 꾸미기 탭 미리보기 수정** (`lib/equipment_page/equipment_page_view.dart`)
- 캐릭터 + 악세서리 모두 96x128 고정 크기로 Stack 겹치기
- 악세서리가 캐릭터 앞에 오도록 Stack 순서 조정 (캐릭터 → 악세서리)
- 상점 카드 및 꾸미기 카드 이미지를 `displayPath`로 변경

**4. 메인화면 캐릭터에 악세서리 표시** (`lib/main_page/home_tab_view.dart`)
- `itemListProvider` 연동하여 장착된 악세서리 실시간 반영
- 유영 애니메이션 중에도 악세서리가 캐릭터와 함께 움직이도록 Stack 처리
- 캐릭터 이미지도 96x128 고정 크기로 통일

**Firestore 작업 필요**
- `items/magic_hat` 문서에 `thumbnailPath: "assets/image/items/magic_hat_tn.png"` 필드 추가 필요

**에셋 작업**
- `magic_hat.png` 이미지 교체 (96x128 캔버스 기준)
- `magic_hat_tn.png` 썸네일 추가

## 2026-04-27

### 장비 페이지 모자 겹침 문제 수정

- 모자 PNG가 독립 크롭 이미지라 캐릭터 몸통 중앙에 겹치던 문제 수정
- 에셋 방식(캔버스 통일) vs 코드 방식 비교 후 코드 방식 채택
- `equipment_page_view.dart` 캐릭터 미리보기 Stack 구조 변경
  - `SizedBox(width: 100, height: 120)` + `alignment: Alignment.bottomCenter`
  - 캐릭터는 바닥 고정, 모자는 `Positioned(top: 0, height: 72)`로 머리 위 배치

### 로컬 푸쉬 알림 구현 (할 일 30분 전)

#### 패키지 추가 (`pubspec.yaml`)

- `flutter_local_notifications: ^18.0.1`
- `timezone: ^0.9.4`

#### Android 설정

- `AndroidManifest.xml`: 권한 4개 추가 (`RECEIVE_BOOT_COMPLETED`, `VIBRATE`, `USE_EXACT_ALARM`, `POST_NOTIFICATIONS`)
- `AndroidManifest.xml`: 예약 알림 리시버 2개 추가 (`ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`)
- `build.gradle.kts`: core library desugaring 활성화 (`isCoreLibraryDesugaringEnabled = true`, `desugar_jdk_libs:2.1.4`)
- `AndroidManifest.xml`: 앱 이름 `flutter_application_1` → `andone` 변경

#### 구현

- `lib/services/notification_service.dart` 신규 생성
  - `init()`: 앱 시작 시 알림 초기화 + Android 13+ 권한 요청
  - `scheduleTodoReminder()`: repeat 타입별 알림 예약
    - `repeat == 0` (반복 없음): startTime 30분 전 1회
    - `repeat == 1` (매일): `DateTimeComponents.time`으로 매일 자동 반복
    - `repeat == 2` (매주): 요일마다 별도 ID로 `DateTimeComponents.dayOfWeekAndTime` 반복
  - `cancelTodoReminder()`: baseId + 요일별 ID(1~7) 전부 취소
  - `_toNotificationId()`: djb2 해시로 docId → 고정 int 변환
  - `_nextWeekday()`: 다음 해당 요일 날짜 계산
- `main.dart`: `notificationService.init()` 초기화 추가
- `todo_create_page_view_model.dart`: todo 생성 시 알림 예약 (repeat, repeatDays 포함)
- `todo_detail_page_view_model.dart`: todo 수정 시 재예약, 삭제 시 취소

## 2026-04-25

### 장비 페이지 UI/UX 구현

#### 기획

- Firestore `items` 컬렉션 설계 (name, category, price, assetPath, description)
- `users/{uid}`에 `ownedItems` (array), `equippedItems` (map) 필드 추가
- 일일 상점은 유저별 랜덤 5개 방식으로 결정 (추후 구현 예정)

#### 구현

- `ItemModel` 추가 (`lib/model/item_model.dart`)
- `EquipmentViewModel` 추가 (`lib/equipment_page/equipment_page_view_model.dart`)
  - `itemListProvider`: Firestore `items` 스트림
  - `purchaseItem()`: 골드 차감 + ownedItems 추가
  - `equipItem()`: equippedItems 맵 업데이트
  - `unequipItem()`: equippedItems 특정 카테고리 삭제
- `UserModel`에 `ownedItems`, `equippedItems` 필드 추가
- `EquipmentPageView` 구현
  - 상단 골드바 (실시간 연결)
  - [상점] / [꾸미기] 탭바
  - 상점 탭: 악세서리/배경 필터 + 2열 그리드, 구매 버튼, 보유중 상태
  - 꾸미기 탭: 캐릭터 미리보기 + 장착 아이템 오버레이, 3열 그리드, 장착중 뱃지
- Firestore 보안 규칙에 `items` 읽기 권한 추가
- `pubspec.yaml`에 `assets/image/items/` 경로 등록

#### 미완료

- 악세서리 픽셀아트 캔버스 크기 조정 필요 (캐릭터와 동일 캔버스 기준으로 위치 맞추기)
- 일일 랜덤 5개 상점 로직 구현 예정

### 매주 반복 Todo 시간 표시 버그 수정

- `effectiveTime`이 오늘 날짜로 무조건 변환해서 오늘이 반복 요일이 아닐 때 "시작됨"이 뜨던 버그 수정
- `weeklyEffectiveTimes` 함수 추가 (Record 타입 반환)
  - 오늘이 반복 요일이고 종료 전이면 오늘 날짜로 계산
  - 아니면 `repeatDays`에서 다음 요일을 탐색해 해당 날짜로 계산
- sort 로직도 동일하게 매주 반복은 `weeklyEffectiveTimes` 기준으로 변경
- `repeat != 0` 조건을 `RepeatType.daily.index` / `RepeatType.weekly.index`로 명시적 분기

### 반복 없는 Todo 표시 범위 확장

- 기존: 오늘 날짜인 todo만 표시
- 변경: 오늘 포함 미래 날짜 todo도 표시 (`startDate >= today`)

## 2026-04-22

### 메인페이지 Todo 시간 표시 로직 개선

- 반복 todo의 남은 시간을 오늘 날짜 기준으로 계산 (`effectiveTime` 함수 추가)
  - 저장된 startTime 날짜가 미래면 그대로 사용
  - 오늘이거나 과거면 오늘 날짜 + 저장된 시간으로 교체
- endTime이 지난 경우 "종료됨" 표시 추가
- 남은 시간 24시간 초과 시 "N일 N시간 전" 형식으로 표시
- todo 정렬 기준을 effectiveTime 기준 오름차순으로 변경 (클라이언트 정렬)

### 프로필 페이지

- 프로필 이미지를 `Icons.person` → 문어 캐릭터 이미지로 변경
- 원형 배경 제거, 이미지만 표시

### UI 정리

- `QuestSectionCard` 상단 블루 그라디언트 라인 제거
- 퀘스트 생성/상세 페이지 상단 그라디언트 라인 제거
