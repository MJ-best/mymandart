# Changelog

## 2025-10-27 - UI/UX 개선 및 기능 복구

### 🎨 UI/UX 개선

#### 1. 네비게이션 최적화
- **모든 페이지에서 상단바 제거**
  - CupertinoNavigationBar 완전 제거
  - 점(StepProgressIndicator)과 화살표 버튼만으로 페이지 이동
  - 만다라트 화면 공간 최대화
  - 파일: `flutter_app/lib/screens/mandalart_app.dart`

#### 2. 진행 표시 점 크기 조정
- **1차 축소**: 14/10 → 4/3 (70% 축소)
- **2차 조정**: 4/3 → 6/5 (최종 크기)
- 너무 작아서 보이지 않는 문제 해결
- 파일: `flutter_app/lib/widgets/step_progress_indicator.dart`

#### 3. Phone 최적화
- **화면 너비 600px 미만일 때 자동 축소**
  - 아이콘 크기: 24px → 20px
  - 버튼 간격: 8px → 4px
  - 패딩: 16px → 8px
- 태블릿에서는 기존 크기 유지
- 파일: `flutter_app/lib/widgets/mandalart_viewer.dart:749-842`

#### 4. 출석체크 위젯 크기 50% 축소
- **크기 조정**
  - 전체 padding: 16 → 10
  - border radius: 16 → 12
  - 아이콘: 48×48 → 32×32

- **폰트 크기**
  - "X일 연속": 24 → 18
  - 상태 텍스트: 13 → 11
  - 단계 설명: 12 → 10
  - 최고 기록: 11 → 9

- **진행바**
  - 높이: 8 → 6
  - 간격: 6 → 3

- 파일: `flutter_app/lib/widgets/streak_widget.dart`

### ✨ 기능 추가 및 복구

#### 1. 3페이지 기능 복구
- **만다라트 뷰어에 모든 기능 버튼 추가**
  - 저장하기 (플로피 디스크 아이콘)
  - 다크모드 토글 (해/달 아이콘)
  - 이미지 저장 (사진 아이콘 - 앱 / 공유 아이콘 - 웹)
  - JSON 내보내기/불러오기 (문서 아이콘)

- **withScaffold=false일 때도 버튼 표시**
  - `_buildActionButtons()` 메서드 추가
  - 세로/가로 레이아웃 모두 지원
  - 파일: `flutter_app/lib/widgets/mandalart_viewer.dart`

#### 2. 도움말 버튼 위치 변경
- **상단바 → 하단으로 이동**
  - 세로 레이아웃: 명언 아래에 도움말 버튼 추가
  - 가로 레이아웃: 사이드바 하단에 도움말 버튼 추가
  - onShowHelp 콜백 추가
  - 파일: `flutter_app/lib/widgets/mandalart_viewer.dart:23,31,228-252,316-340`

#### 3. 이전 만다라트 보기 기능
- **랜딩 페이지에 버튼 추가**
  - 저장된 만다라트 목록으로 이동
  - 테두리가 있는 버튼 디자인으로 일관성 유지
  - 파일: `flutter_app/lib/screens/landing_screen.dart:240-283`

#### 4. 사용자 상태 저장/복원
- **SharedPreferences 활용**
  - has_started 플래그로 사용자 진행 상태 저장
  - 처음 방문: 랜딩 페이지 표시
  - "나의 만다라트 만들기" 클릭: 플래그 저장
  - 다음 방문: 자동으로 만다라트 뷰어(3페이지)로 이동

- **구현 파일**
  - GoRouter redirect 로직: `flutter_app/lib/main.dart:16-28`
  - 플래그 저장: `flutter_app/lib/screens/landing_screen.dart:221-222`
  - 3페이지로 자동 이동: `flutter_app/lib/screens/mandalart_app.dart:35-47`

### 📝 텍스트 개선

#### 용어 정리
- **"이 목표를 실현하기 위한 8가지 핵심 영역"** → **"8가지 핵심영역"**
  - `flutter_app/lib/widgets/steps/combined_step.dart:209`
  - `flutter_app/lib/widgets/steps/themes_step.dart:146`

- **"이 영역을 달성하기 위한 8가지 구체적 행동"** → **"8가지 측정가능한 구체적 행동"**
  - `flutter_app/lib/widgets/steps/combined_step.dart:419`
  - `flutter_app/lib/widgets/steps/actions_step.dart:301`

- **"핵심 영역이 각각 8가지 구체적 행동"** → **"핵심영역이 각각 8가지 측정가능한 구체적 행동"**
  - `flutter_app/lib/widgets/steps/actions_step.dart:170`

### 🔧 기술적 개선

#### 1. 반응형 디자인
- MediaQuery를 활용한 화면 크기별 최적화
- Phone(< 600px)과 Tablet(≥ 600px) 구분
- 아이콘, 간격, 패딩 자동 조정

#### 2. 상태 관리
- SharedPreferences로 영구 저장
- Riverpod 상태 관리 유지
- GoRouter redirect로 자동 네비게이션

#### 3. 레이아웃 최적화
- SafeArea 활용으로 모든 디바이스 지원
- 세로/가로 모드 모두 지원
- InteractiveViewer로 확대/축소 가능

### 📱 사용자 경험 개선

#### 처음 방문 사용자
1. 랜딩 페이지에서 만다라트 소개 확인
2. "나의 만다라트 만들기" 클릭
3. 3단계로 만다라트 작성 (목표 → 핵심영역 → 구체적 행동)

#### 재방문 사용자
1. 앱 실행 시 자동으로 만다라트 뷰어로 이동
2. 저장/이미지저장/JSON 기능 즉시 접근 가능
3. 출석체크로 습관 형성 추적

#### 저장된 만다라트 관리
1. 랜딩 페이지의 "이전 만다라트 보기" 버튼
2. 뷰어의 저장 버튼으로 새로운 만다라트 저장
3. JSON 내보내기/불러오기로 데이터 백업

### 🎯 주요 성과

1. **화면 활용도 증가**: 상단바 제거로 만다라트 표시 영역 확대
2. **접근성 향상**: Phone에서도 편리하게 사용 가능
3. **기능 복구**: 3페이지에서 모든 핵심 기능 사용 가능
4. **사용자 경험**: 재방문 시 바로 만다라트 확인 가능
5. **일관성**: 텍스트 용어 정리로 명확한 의미 전달

### 📊 변경 통계

- 수정된 파일: 9개
- 추가된 기능: 4개
- UI 개선: 5개
- 텍스트 수정: 5곳

---

## 향후 개선 계획

- [ ] 만다라트 템플릿 기능
- [ ] 소셜 공유 기능
- [ ] 진행률 그래프 시각화
- [ ] 알림 기능 (출석 체크 리마인더)
- [ ] 테마 커스터마이징
