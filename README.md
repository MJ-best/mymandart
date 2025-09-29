# 만다라트 저니 (Mandalart Journey) 🎯

만다라트를 쉽게 만들고 공유하는 웹 애플리케이션입니다. 목표 설정과 시각화를 통해 개인의 성장과 발전을 돕습니다.

## ✨ 주요 기능

### 1. 3단계 만다라트 생성 과정
- **1단계**: 한 문장으로 나의 목표 정의
- **2단계**: 8가지 핵심 테마 설정
- **3단계**: 각 테마별 8개 액션 아이템 작성

### 2. 스마트 키워드 추천 시스템
- 목표, 테마, 액션 아이템별 맞춤 키워드 제공
- 템플릿을 통한 쉬운 시작
- 카테고리별 키워드 분류 (형용사, 명사, 동사)

### 3. 실시간 진행 상황 추적
- 테마별 완성도 표시
- 액션 아이템 체크박스로 진행 관리
- 전체 완성도 시각화

### 4. 만다라트 시각화 및 공유
- 9x9 그리드 형태의 만다라트 차트
- 테마별 상세 보기
- 이미지 및 JSON 형태로 내보내기
- 실시간 색상 변화로 완료 상태 표시

## 🚀 기술 스택

- **Frontend**: React 18 + TypeScript
- **Styling**: Tailwind CSS + shadcn/ui
- **Build Tool**: Vite
- **State Management**: React Hooks + LocalStorage
- **Export**: html2canvas for image export
- **Icons**: Lucide React

## 📦 설치 및 실행

1. **의존성 설치:**
   ```bash
   npm install
   ```

2. **개발 서버 실행:**
   ```bash
   npm run dev
   ```

3. **브라우저에서 확인:**
   `http://localhost:5173`에서 애플리케이션을 확인하세요.

## 🎯 사용 방법

### 1단계: 목표 정의
- 템플릿을 선택하거나 직접 입력
- 키워드 추천을 활용하여 구체적인 목표 작성
- 최소 10자 이상 입력 필요

### 2단계: 테마 설정
- 목표 달성을 위한 8가지 핵심 영역 정의
- 각 테마별 키워드 추천 활용
- 모든 테마를 채워야 다음 단계 진행 가능

### 3단계: 액션 아이템 작성
- 각 테마별로 8개의 구체적인 행동 계획 수립
- 체크박스로 완료 상태 관리
- 실시간으로 진행 상황 확인

### 만다라트 보기
- 완성된 만다라트를 시각적으로 확인
- 테마별 상세 보기 가능
- 이미지나 JSON으로 내보내기

## 📁 프로젝트 구조

```
src/
├── components/
│   ├── steps/              # 3단계 컴포넌트
│   │   ├── GoalDefinitionStep.tsx
│   │   ├── ThemeStep.tsx
│   │   └── ActionItemsStep.tsx
│   ├── ui/                 # shadcn/ui 컴포넌트
│   ├── KeywordChips.tsx    # 키워드 추천 컴포넌트
│   ├── MandalartApp.tsx    # 메인 앱 컴포넌트
│   ├── MandalartViewer.tsx # 만다라트 뷰어
│   ├── MandalartGrid.tsx   # 만다라트 그리드
│   └── ProgressIndicator.tsx # 진행 상황 표시
├── data/
│   └── keywords.ts         # 키워드 데이터
├── hooks/
│   └── useLocalStorage.ts  # 로컬 스토리지 훅
├── types/
│   └── mandalart.ts        # 타입 정의
├── utils/
│   ├── uuid.ts            # UUID 생성
│   ├── mandalartGrid.ts   # 그리드 생성 로직
│   └── mandalartExport.ts # 내보내기 기능
└── pages/
    └── Index.tsx          # 메인 페이지
```

## 🎨 주요 컴포넌트

### MandalartApp
- 전체 앱의 상태 관리
- 3단계 플로우 제어
- 로컬 스토리지 연동

### KeywordChips
- 키워드 추천 UI
- 카테고리별 색상 구분
- 툴팁으로 설명 제공

### MandalartGrid
- 9x9 그리드 렌더링
- 테마별 상세 보기
- 완료 상태 시각화

### ProgressIndicator
- 실시간 진행 상황 표시
- 테마 및 액션 아이템 완성도
- 전체 완성도 시각화

## 💾 데이터 모델

```typescript
interface Goal {
  id: string;
  centralGoal: string;
  createdAt: Date;
  updatedAt: Date;
}

interface Theme {
  id: string;
  goalId: string;
  themeText: string;
  order: number;
  createdAt: Date;
  updatedAt: Date;
}

interface ActionItem {
  id: string;
  themeId: string;
  actionText: string;
  isCompleted: boolean;
  order: number;
  createdAt: Date;
  updatedAt: Date;
}
```

## 🔧 개발 스크립트

- `npm run dev` - 개발 서버 실행
- `npm run build` - 프로덕션 빌드
- `npm run preview` - 빌드 미리보기
- `npm run lint` - 코드 린팅

## 📱 반응형 디자인

- 모바일, 태블릿, 데스크톱 지원
- 터치 친화적 인터페이스
- 적응형 레이아웃

## 🎯 향후 개선 사항

- [ ] 다중 만다라트 관리
- [ ] 목표 달성 통계
- [ ] 소셜 공유 기능
- [ ] 오프라인 지원
- [ ] 다국어 지원

## 📄 라이선스

MIT License

---

**만다라트 저니**로 당신의 목표를 시각화하고 달성해보세요! 🚀