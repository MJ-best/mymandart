import 'package:mandarart_journey/models/mandalart.dart';
import 'package:uuid/uuid.dart';

/// 오타니 쇼헤이의 만다라트 예시 데이터
class OhtaniMandalartExample {
  static MandalartStateModel get data {
    const uuid = Uuid();
    final now = DateTime.now();

    // 8가지 핵심 영역
    final themeTexts = [
      '체력',
      '컨트롤',
      '구위 160km/h',
      '멘탈',
      '인간성',
      '운',
      '변화구',
      '스피드',
    ];

    final themes = List<ThemeModel>.generate(
        8,
        (i) => ThemeModel(
              id: uuid.v4(),
              goalId: 'ohtani_goal',
              themeText: themeTexts[i],
              order: i,
              priority: GoalPriority.high, // Example priority
              createdAt: now,
              updatedAt: now,
            ));

    // 각 테마별 8가지 액션 아이템
    final actionsData = [
      // Theme 0: 체력
      [
        'RSQ 130kg',
        '체간 강화',
        '유연성 향상',
        '하체 강화',
        '식단 관리',
        '체지방 감소',
        '90kg 체중 달성',
        '스태미나 향상',
      ],
      // Theme 1: 컨트롤
      [
        '투구 폼 안정화',
        '리듬 만들기',
        '앞으로 내밀기',
        '콘트롤 좋게',
        '체간 축 안정화',
        '투구수 줄이기',
        '안정감',
        '완투',
      ],
      // Theme 2: 구위 160km/h
      [
        '다리 강화',
        '가동역 넓히기',
        '체간 강화',
        '체중 증가',
        '유연성',
        '손목 강화',
        '스피드건 측정',
        '회전수 향상',
      ],
      // Theme 3: 멘탈
      [
        '심호흡',
        '과감한 도전',
        '인내심',
        '전투적인 마음',
        '평정심',
        '뚝심',
        '긍정적 사고',
        '흔들리지 않는 마음',
      ],
      // Theme 4: 인간성
      [
        '감사하는 마음',
        '예의',
        '배려',
        '신뢰받기',
        '사랑받는 인간',
        '계획성',
        '생각의 깊이',
        '양심',
      ],
      // Theme 5: 운
      [
        '인사하기',
        '쓰레기 줍기',
        '방 청소',
        '용구 손질',
        '책 읽기',
        '긍정적인 말',
        '심부름 하기',
        '응원 받기',
      ],
      // Theme 6: 변화구
      [
        '슬라이더',
        '커브',
        '체인지업',
        '스플리터',
        '변화의 크기',
        '정확도',
        '날카로움',
        '회전수',
      ],
      // Theme 7: 스피드
      [
        '다리 강화',
        '유연성',
        '체간',
        '가동역 넓히기',
        '빠른 판단',
        '첫걸음의 빠르기',
        '주루 기술',
        '50m 5.9초',
      ],
    ];

    // ActionItemModel 생성
    final actionItems = <ActionItemModel>[];
    for (int themeIndex = 0; themeIndex < 8; themeIndex++) {
      for (int actionIndex = 0; actionIndex < 8; actionIndex++) {
        actionItems.add(ActionItemModel(
          id: uuid.v4(),
          themeId: 'theme-$themeIndex',
          actionText: actionsData[themeIndex][actionIndex],
          status: ActionStatus.notStarted, // 예시이므로 모두 시작 전 상태
          order: actionIndex,
          createdAt: now,
          updatedAt: now,
        ));
      }
    }

    return MandalartStateModel(
      displayName: '오타니 쇼헤이의 야구 여정',
      goalText: '8구단 드래프트 1위 지명',
      themes: themes,
      actionItems: actionItems,
      currentStep: 0, // 기본값: Viewer
      showViewer: false,
      calendarLog: const {},
    );
  }
}
