// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Mandarat';

  @override
  String get myMandalart => '나만의 만다라트';

  @override
  String get landingTitle => '만다라트로 여정을 디자인하세요';

  @override
  String get landingSubtitle => '오타니처럼 꿈꾸고, Mandarat으로 이루세요.';

  @override
  String get createMandalart => '나의 만다라트 만들기';

  @override
  String get viewSavedMandalarts => '이전 만다라트 보기';

  @override
  String get eightCoreAreas => '8가지 핵심영역';

  @override
  String get eightMeasurableActions => '8가지 측정가능한 구체적 행동';

  @override
  String get goalPlaceholder => '예: 메이저리그 진출';

  @override
  String get themePlaceholder => '예: 체력 향상';

  @override
  String get actionPlaceholder => '예: RSQ 130kg 달성하기';

  @override
  String get save => '저장하기';

  @override
  String get delete => '삭제';

  @override
  String get cancel => '취소';

  @override
  String get confirm => '확인';

  @override
  String get edit => '수정';

  @override
  String get close => '닫기';

  @override
  String get help => '도움말';

  @override
  String get savedMandalarts => '저장된 만다라트';

  @override
  String get noSavedMandalarts => '아직 저장된 만다라트가 없습니다';

  @override
  String consecutiveDays(int days) {
    return '$days일 연속';
  }

  @override
  String longestStreak(int days) {
    return '최고 $days일';
  }

  @override
  String get checkInSuccess => '출석 완료!';

  @override
  String get alreadyCheckedIn => '이미 출석했습니다';

  @override
  String get exportJson => 'JSON 내보내기 (클립보드 복사)';

  @override
  String get importJson => 'JSON 불러오기 (클립보드에서)';

  @override
  String get saveImage => '이미지 저장';

  @override
  String get downloadImage => '이미지 다운로드';

  @override
  String get tip1Title => '형용사 사용금지';

  @override
  String get tip1Description =>
      '운동열심히하기 ✗ → RSQ 130kg 달성하기 ✓\n측정 가능한 구체적 목표를 설정하세요.';

  @override
  String get tip2Title => '측정가능한 지표 설정';

  @override
  String get tip2Description => '밥 10그릇 먹기처럼 명확하게 측정할 수 있는\n숫자와 단위를 포함하세요.';

  @override
  String get tip3Title => '일상 루틴으로 통합';

  @override
  String get tip3Description =>
      '운을 키우기 ✗ → 매일 쓰레기 줍기 ✓\n매일 실행할 수 있는 구체적 행동으로 만드세요.';

  @override
  String get tip4Title => '66일 습관화 법칙';

  @override
  String get tip4Description => '21일 의식적 실행 단계를 거쳐\n66일 무의식 습관화 단계로 나아가세요.';

  @override
  String get journeyNamePrompt => '앱에서 당신의 여정을 어떻게 부를까요?';

  @override
  String get journeyNamePlaceholder => '예: 나의 메이저리그 여정';
}
