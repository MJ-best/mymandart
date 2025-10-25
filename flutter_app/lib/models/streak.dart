/// 출석체크 스트릭 상태
enum StreakStatus {
  /// 재만 남음 (2일 이상 빠짐)
  ash,

  /// 연기만 남음 (1일 빠짐)
  smoke,

  /// 불이 붙음 (2일 연속)
  fire,

  /// 불이 엄청 쎄짐 (3일 이상 연속)
  strongFire;

  String toJson() => name;

  static StreakStatus fromJson(String value) {
    return StreakStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StreakStatus.ash,
    );
  }
}

/// 출석체크 스트릭 모델
class StreakModel {
  /// 현재 연속 출석 일수
  final int currentStreak;

  /// 최고 연속 출석 일수
  final int longestStreak;

  /// 마지막 출석 날짜
  final DateTime? lastCheckInDate;

  /// 현재 스트릭 상태
  final StreakStatus status;

  /// 총 출석 일수
  final int totalCheckIns;

  const StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCheckInDate,
    required this.status,
    required this.totalCheckIns,
  });

  factory StreakModel.initial() => const StreakModel(
        currentStreak: 0,
        longestStreak: 0,
        lastCheckInDate: null,
        status: StreakStatus.ash,
        totalCheckIns: 0,
      );

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCheckInDate,
    StreakStatus? status,
    int? totalCheckIns,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      status: status ?? this.status,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCheckInDate': lastCheckInDate?.toIso8601String(),
      'status': status.toJson(),
      'totalCheckIns': totalCheckIns,
    };
  }

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCheckInDate: json['lastCheckInDate'] != null
          ? DateTime.tryParse(json['lastCheckInDate'] as String)
          : null,
      status: StreakStatus.fromJson(json['status'] as String? ?? 'ash'),
      totalCheckIns: json['totalCheckIns'] as int? ?? 0,
    );
  }

  /// 21일 의식적 실행 단계를 달성했는지
  bool get hasReachedConscious => currentStreak >= 21;

  /// 66일 무의식 습관화 단계를 달성했는지
  bool get hasReachedHabit => currentStreak >= 66;

  /// 현재 단계 설명
  String get phaseDescription {
    if (currentStreak >= 66) {
      return '66일 무의식 습관화 완료!';
    } else if (currentStreak >= 21) {
      return '21일 의식적 실행 완료! ${66 - currentStreak}일 남음';
    } else if (currentStreak > 0) {
      return '21일 의식적 실행까지 ${21 - currentStreak}일 남음';
    } else {
      return '매일 출석하여 습관을 만들어보세요';
    }
  }
}
