import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// Application title
  ///
  /// In ko, this message translates to:
  /// **'Mandarat'**
  String get appTitle;

  /// My Mandalart title
  ///
  /// In ko, this message translates to:
  /// **'나만의 만다라트'**
  String get myMandalart;

  /// Landing page main title
  ///
  /// In ko, this message translates to:
  /// **'만다라트로 여정을 디자인하세요'**
  String get landingTitle;

  /// Landing page subtitle
  ///
  /// In ko, this message translates to:
  /// **'오타니처럼 꿈꾸고, Mandarat으로 이루세요.'**
  String get landingSubtitle;

  /// Create mandalart button
  ///
  /// In ko, this message translates to:
  /// **'나의 만다라트 만들기'**
  String get createMandalart;

  /// View saved mandalarts button
  ///
  /// In ko, this message translates to:
  /// **'이전 만다라트 보기'**
  String get viewSavedMandalarts;

  /// 8 core areas
  ///
  /// In ko, this message translates to:
  /// **'8가지 핵심영역'**
  String get eightCoreAreas;

  /// 8 measurable concrete actions
  ///
  /// In ko, this message translates to:
  /// **'8가지 측정가능한 구체적 행동'**
  String get eightMeasurableActions;

  /// Goal input placeholder
  ///
  /// In ko, this message translates to:
  /// **'예: 메이저리그 진출'**
  String get goalPlaceholder;

  /// Theme input placeholder
  ///
  /// In ko, this message translates to:
  /// **'예: 체력 향상'**
  String get themePlaceholder;

  /// Action input placeholder
  ///
  /// In ko, this message translates to:
  /// **'예: RSQ 130kg 달성하기'**
  String get actionPlaceholder;

  /// Save button
  ///
  /// In ko, this message translates to:
  /// **'저장하기'**
  String get save;

  /// Delete button
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get delete;

  /// Cancel button
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// Confirm button
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// Edit button
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get edit;

  /// Close button
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// Help button
  ///
  /// In ko, this message translates to:
  /// **'도움말'**
  String get help;

  /// Saved mandalarts screen title
  ///
  /// In ko, this message translates to:
  /// **'저장된 만다라트'**
  String get savedMandalarts;

  /// No saved mandalarts message
  ///
  /// In ko, this message translates to:
  /// **'아직 저장된 만다라트가 없습니다'**
  String get noSavedMandalarts;

  /// Consecutive days streak
  ///
  /// In ko, this message translates to:
  /// **'{days}일 연속'**
  String consecutiveDays(int days);

  /// Longest streak
  ///
  /// In ko, this message translates to:
  /// **'최고 {days}일'**
  String longestStreak(int days);

  /// Check-in success message
  ///
  /// In ko, this message translates to:
  /// **'출석 완료!'**
  String get checkInSuccess;

  /// Already checked in message
  ///
  /// In ko, this message translates to:
  /// **'이미 출석했습니다'**
  String get alreadyCheckedIn;

  /// Export JSON button
  ///
  /// In ko, this message translates to:
  /// **'JSON 내보내기 (클립보드 복사)'**
  String get exportJson;

  /// Import JSON button
  ///
  /// In ko, this message translates to:
  /// **'JSON 불러오기 (클립보드에서)'**
  String get importJson;

  /// Save image button
  ///
  /// In ko, this message translates to:
  /// **'이미지 저장'**
  String get saveImage;

  /// Download image button
  ///
  /// In ko, this message translates to:
  /// **'이미지 다운로드'**
  String get downloadImage;

  /// Tip 1 title
  ///
  /// In ko, this message translates to:
  /// **'형용사 사용금지'**
  String get tip1Title;

  /// Tip 1 description
  ///
  /// In ko, this message translates to:
  /// **'운동열심히하기 ✗ → RSQ 130kg 달성하기 ✓\n측정 가능한 구체적 목표를 설정하세요.'**
  String get tip1Description;

  /// Tip 2 title
  ///
  /// In ko, this message translates to:
  /// **'측정가능한 지표 설정'**
  String get tip2Title;

  /// Tip 2 description
  ///
  /// In ko, this message translates to:
  /// **'밥 10그릇 먹기처럼 명확하게 측정할 수 있는\n숫자와 단위를 포함하세요.'**
  String get tip2Description;

  /// Tip 3 title
  ///
  /// In ko, this message translates to:
  /// **'일상 루틴으로 통합'**
  String get tip3Title;

  /// Tip 3 description
  ///
  /// In ko, this message translates to:
  /// **'운을 키우기 ✗ → 매일 쓰레기 줍기 ✓\n매일 실행할 수 있는 구체적 행동으로 만드세요.'**
  String get tip3Description;

  /// Tip 4 title
  ///
  /// In ko, this message translates to:
  /// **'66일 습관화 법칙'**
  String get tip4Title;

  /// Tip 4 description
  ///
  /// In ko, this message translates to:
  /// **'21일 의식적 실행 단계를 거쳐\n66일 무의식 습관화 단계로 나아가세요.'**
  String get tip4Description;

  /// Journey name prompt
  ///
  /// In ko, this message translates to:
  /// **'앱에서 당신의 여정을 어떻게 부를까요?'**
  String get journeyNamePrompt;

  /// Journey name placeholder
  ///
  /// In ko, this message translates to:
  /// **'예: 나의 메이저리그 여정'**
  String get journeyNamePlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
