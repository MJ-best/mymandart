# Mandalart Journey App - Improvement Instructions

## 개선 요구사항

### 1. Step 1: 다른 사람들의 목표 표시
**목적**: 사용자가 다른 사람들과 연결되어 있다는 느낌 제공

**구현 방법**:
- 100가지의 새해 목표 데이터 준비
- Step 1 화면에 랜덤하게 선택된 목표들을 표시
- "다른 사람들은 이런 목표를 세우고 있어요" 섹션 추가
- 실시간 연결 대신 미리 준비된 목표 목록 사용

**기술적 접근**:
- `keywords.dart`에 100개의 새해 목표 리스트 추가
- 랜덤 선택 알고리즘으로 3-5개 표시
- 슬라이딩 애니메이션으로 순환 표시 (선택적)

---

### 2. 완료 색상 변경: 보라색 테마로 통일
**현재 문제**: 완료된 항목이 초록색으로 표시되어 너무 튐

**변경 사항**:
- 완료 색상: `CupertinoColors.systemGreen` → `CupertinoColors.systemPurple`
- 앱 전체 테마 컬러를 보라색 계열로 통일
- 완료된 액션 아이템 배경도 부드러운 보라색 톤 사용

**적용 위치**:
- `MandalartAppScreen`: CupertinoSwitch activeTrackColor
- `MandalartViewer`: 완료된 셀 배경색
- 기타 강조 색상

---

### 3. Step 2: 액션 아이템 폴딩/언폴딩 (Accordion)
**현재 문제**: 8개 테마의 액션 아이템이 모두 펼쳐져 있어 산만함

**변경 사항**:
- 각 테마 카드를 접을 수 있도록 변경 (Accordion/Collapsible)
- 기본 상태: 모두 접힌 상태
- 테마 제목 탭하면 해당 테마의 8개 액션 아이템 표시
- 한 번에 하나의 테마만 펼쳐지도록 (선택적)

**구현 방법**:
- `ExpansionTile` 또는 커스텀 Collapsible 위젯 사용
- 상태 관리: 어떤 테마가 펼쳐져 있는지 추적
- 애니메이션: iOS 스타일 부드러운 expand/collapse

---

### 4. Step 3: Toggle → Checkbox 변경
**현재**: CupertinoSwitch (토글) 사용
**변경**: CupertinoCheckbox 사용

**이유**:
- 완료/미완료 표시에는 체크박스가 더 직관적
- 공간 효율성 향상
- 시각적으로 덜 산만함

**적용**:
- `_ActionsStep`의 CupertinoSwitch를 CupertinoCheckbox로 교체
- 체크박스 선택 시 햅틱 피드백 유지
- 체크된 항목은 보라색 체크마크 표시

---

## 구현 우선순위

1. **High Priority**:
   - 완료 색상 변경 (보라색 테마)
   - Toggle → Checkbox 변경

2. **Medium Priority**:
   - Step 2 액션 아이템 폴딩 기능

3. **Low Priority**:
   - Step 1 랜덤 목표 표시

---

## 완료 체크리스트

- [ ] 100개의 새해 목표 데이터 추가
- [ ] Step 1에 랜덤 목표 표시 기능 구현
- [ ] 전체 앱 테마를 보라색으로 변경
- [ ] 완료 색상 초록 → 보라 변경
- [ ] Step 2에 Accordion/Collapsible 추가
- [ ] CupertinoSwitch → CupertinoCheckbox 교체
- [ ] 모든 변경사항 테스트 (iOS/Android)
- [ ] Hot reload로 즉시 확인

---

**참고**: 모든 변경사항은 iOS 디자인 가이드라인을 준수하며, 햅틱 피드백과 접근성 기능을 유지해야 합니다.
