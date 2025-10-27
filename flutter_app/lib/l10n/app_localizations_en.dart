// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mandarat';

  @override
  String get myMandalart => 'My Mandalart';

  @override
  String get landingTitle => 'Design Your Journey with Mandalart';

  @override
  String get landingSubtitle => 'Dream like Ohtani, achieve with Mandarat.';

  @override
  String get createMandalart => 'Create My Mandalart';

  @override
  String get viewSavedMandalarts => 'View Saved Mandalarts';

  @override
  String get eightCoreAreas => '8 Core Areas';

  @override
  String get eightMeasurableActions => '8 Measurable Concrete Actions';

  @override
  String get goalPlaceholder => 'e.g., Join Major League';

  @override
  String get themePlaceholder => 'e.g., Improve Physical Strength';

  @override
  String get actionPlaceholder => 'e.g., Achieve RSQ 130kg';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'OK';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get help => 'Help';

  @override
  String get savedMandalarts => 'Saved Mandalarts';

  @override
  String get noSavedMandalarts => 'No saved mandalarts yet';

  @override
  String consecutiveDays(int days) {
    return '$days days streak';
  }

  @override
  String longestStreak(int days) {
    return 'Best $days days';
  }

  @override
  String get checkInSuccess => 'Check-in Complete!';

  @override
  String get alreadyCheckedIn => 'Already checked in today';

  @override
  String get exportJson => 'Export JSON (Copy to Clipboard)';

  @override
  String get importJson => 'Import JSON (From Clipboard)';

  @override
  String get saveImage => 'Save Image';

  @override
  String get downloadImage => 'Download Image';

  @override
  String get tip1Title => 'No Adjectives';

  @override
  String get tip1Description =>
      'Exercise hard ✗ → Achieve RSQ 130kg ✓\nSet specific, measurable goals.';

  @override
  String get tip2Title => 'Set Measurable Metrics';

  @override
  String get tip2Description =>
      'Include clear numbers and units that can be\nmeasured, like eating 10 bowls of rice.';

  @override
  String get tip3Title => 'Integrate into Daily Routine';

  @override
  String get tip3Description =>
      'Build luck ✗ → Pick up trash daily ✓\nMake it a concrete action you can do every day.';

  @override
  String get tip4Title => '66-Day Habit Rule';

  @override
  String get tip4Description =>
      'Through 21 days of conscious execution,\nreach the 66-day unconscious habit stage.';

  @override
  String get journeyNamePrompt => 'What would you like to call your journey?';

  @override
  String get journeyNamePlaceholder => 'e.g., My Major League Journey';
}
