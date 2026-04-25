# andone 작업 로그

<!-- Claude가 세션 종료 시 자동으로 기록합니다 -->

## 2026-04-25

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

