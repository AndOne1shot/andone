# andone 🐙

할 일을 완료하며 나만의 문어 캐릭터를 키우는 다마고치 스타일 Todo 앱 (작업 진행중)

---

## 📱 주요 기능

### ✅ Todo (퀘스트)
- 퀘스트 생성 / 수정 / 삭제
- 난이도 설정 (1~5단계)
- 반복 설정 (없음 / 매일 / 매주 요일 지정)
- 시작일 및 시간 범위 설정
- 완료 처리 (완료 후 취소 불가)
- 오늘 날짜 기준 퀘스트 자동 필터링

### 🐙 캐릭터 시스템
- 문어 픽셀 아트 캐릭터 (좌우 유영 애니메이션)
- 기분 수치 (0~100) - 퀘스트 완료 시 상승
- 골드 - 난이도에 따라 퀘스트 완료 시 획득

### 👤 계정
- 이메일/비밀번호 회원가입 (닉네임 포함)
- 로그인 / 로그아웃
- 계정별 독립적인 데이터 관리

### 📊 프로필
- 기분 / 골드 스탯 표시
- 누적 퀘스트 달성 수 + 마일스톤 진행도
- 이번 주 요일별 달성 막대 그래프
- 월별 달성 캘린더 (탭하면 달성 수 표시)

### 🗂️ 탭 구성
| 탭 | 설명 |
|----|------|
| 홈 | 문어 캐릭터 + 오늘의 퀘스트 목록 |
| 장비 | 준비 중 |
| 프로필 | 스탯, 활동 기록, 로그아웃 |

---

## 🛠️ 기술 스택

| 항목 | 내용 |
|------|------|
| Framework | Flutter |
| 상태관리 | Flutter Riverpod ^3.2.1 |
| 인증 | Firebase Auth ^6.1.4 |
| DB | Cloud Firestore ^6.1.2 |
| 아키텍처 | MVVM |

---

## 🗄️ Firestore 구조

로그인한 유저의 UID를 기준으로 각 유저마다 독립적인 컬렉션이 생성됩니다.

```
users/                              # 컬렉션
  {uid}/                            # 유저 문서 (Firebase Auth UID)
    ├─ email                String
    ├─ nickname             String
    ├─ mood                 int       (0~100)
    ├─ maxMood              int
    ├─ gold                 int
    ├─ totalCompleted       int       (누적 퀘스트 완료 수)
    │
    ├─ todos/                        # 서브컬렉션 (유저별 독립)
    │   {todoId}/                    # Todo 문서 (자동 생성 ID)
    │     ├─ title                   String
    │     ├─ content                 String
    │     ├─ difficulty              int         (1~5)
    │     ├─ startTime               Timestamp
    │     ├─ endTime                 Timestamp
    │     ├─ isCompleted             bool
    │     ├─ repeat                  int         (0=없음, 1=매일, 2=매주)
    │     ├─ repeatDays              List<int>   (1=월 ~ 7=일, 매주일 때만 사용)
    │     └─ lastCompletedDate       String?     (yyyy-MM-dd, 반복 todo 완료 날짜)
    │
    └─ completedHistory/             # 서브컬렉션 (날짜별 완료 기록)
        {yyyy-MM-dd}/                # 날짜 문서
          └─ count                  int         (해당 날짜 완료 수)
```

---

## 📁 프로젝트 구조

```
lib/
├─ main.dart
├─ auth_service.dart
├─ model/
│   ├─ user_model.dart
│   └─ todo_model.dart
├─ providers/
│   └─ user_provider.dart
├─ login_page/
├─ sign_up_page/
├─ main_page/
│   ├─ main_page_view.dart
│   ├─ main_page_view_model.dart
│   └─ home_tab_view.dart
├─ todo_create_page/
├─ todo_detail_page/
├─ equipment_page/
└─ profile_page/
```

---

## 🚀 시작하기 (개발자용)

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. Firebase 설정
- `google-services.json` (Android) 파일을 `android/app/` 경로에 추가
- ※ 사용자가 앱을 설치할 때는 필요 없음

### 3. 실행
```bash
flutter run
```

---

## 🗺️ 로드맵

- [ ] 꾸미기 시스템 (악세서리, 배경 소품 상점)
- [ ] 기분 수치 시간 경과에 따른 자동 감소
- [ ] 캐릭터 상태별 스프라이트 (기쁨/슬픔/지침)
- [ ] 로컬 푸시 알림
