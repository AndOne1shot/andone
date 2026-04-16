# andone

할 일을 완료하며 나만의 캐릭터를 키우는 Todo 앱

---

## 📱 주요 기능

### ✅ Todo (퀘스트)

- 퀘스트 생성 / 수정 / 삭제
- 난이도 설정 (1~5단계)
- 반복 설정 (없음 / 매일 / 매주 요일 지정)
- 시작일 및 시간 범위 설정
- 완료 처리 (완료 후 취소 불가)

### 👤 계정

- 이메일/비밀번호 회원가입 (닉네임 포함)
- 로그인 / 로그아웃
- 계정별 독립적인 데이터 관리

---

## 🛠️ 기술 스택

| 항목      | 내용                    |
| --------- | ----------------------- |
| Framework | Flutter                 |
| 상태관리  | Flutter Riverpod ^3.2.1 |
| 인증      | Firebase Auth ^6.1.4    |
| DB        | Cloud Firestore ^6.1.2  |
| 아키텍처  | MVVM                    |

---

## 🗄️ Firestore 구조

로그인한 유저의 UID를 기준으로 각 유저마다 독립적인 컬렉션이 생성됩니다.

```
users/                          # 컬렉션
  {uid}/                        # 유저 문서 (Firebase Auth UID)
    ├─ nickname       String
    ├─ level          int
    ├─ exp            int
    ├─ maxExp         int
    ├─ hp             int
    ├─ maxHp          int
    ├─ atk            int
    │
    ├─ todos/                   # 서브컬렉션 (유저별 독립)
    │   {todoId}/               # Todo 문서 (자동 생성 ID)
    │     ├─ title              String
    │     ├─ content            String
    │     ├─ difficulty         int         (1~5)
    │     ├─ startTime          Timestamp
    │     ├─ endTime            Timestamp
    │     ├─ isCompleted        bool
    │     ├─ repeat             int         (0=없음, 1=매일, 2=매주)
    │     ├─ repeatDays         List<int>   (1=월 ~ 7=일, 매주일 때만 사용)
    │     └─ lastCompletedDate  String?     (yyyy-MM-dd, 반복 todo 완료 날짜)
    │
    └─ monsters/                # 서브컬렉션 (유저별 독립)
        {monsterId}/            # 몬스터 문서 (자동 생성 ID)
          ├─ monsterId          int
          ├─ monsterName        String
          ├─ hp                 int
          ├─ maxHp              int
          ├─ atk                int
          ├─ monsterLevel       int
          └─ rewardExp          int
```

---

## 📁 프로젝트 구조

```
lib/
├─ main.dart
├─ auth_service.dart
├─ model/
│   ├─ user_model.dart
│   ├─ todo_model.dart
│   └─ monster_model.dart
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

## 🚀 시작하기

### 1. 의존성 설치

```bash
flutter pub get
```

### 2. Firebase 설정

- `google-services.json` (Android) 파일을 `android/app/` 경로에 추가

### 3. 실행

```bash
flutter run
```
