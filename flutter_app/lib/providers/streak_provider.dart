import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mandarart_journey/models/streak.dart';

class StreakNotifier extends StateNotifier<StreakModel> {
  StreakNotifier() : super(StreakModel.initial()) {
    _load();
  }

  static const _keyStreak = 'streak-data';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final streakJson = prefs.getString(_keyStreak);

    if (streakJson != null) {
      try {
        final data = jsonDecode(streakJson) as Map<String, dynamic>;
        final loadedStreak = StreakModel.fromJson(data);

        // 로드 후 상태 업데이트 확인
        state = _updateStreakStatus(loadedStreak);
        await _persist();
      } catch (e) {
        // 파싱 오류 시 초기화
        state = StreakModel.initial();
      }
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStreak, jsonEncode(state.toJson()));
  }

  /// 스트릭 상태를 현재 날짜 기준으로 업데이트
  StreakModel _updateStreakStatus(StreakModel currentStreak) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (currentStreak.lastCheckInDate == null) {
      return currentStreak;
    }

    final lastCheckIn = DateTime(
      currentStreak.lastCheckInDate!.year,
      currentStreak.lastCheckInDate!.month,
      currentStreak.lastCheckInDate!.day,
    );

    final daysDifference = today.difference(lastCheckIn).inDays;

    if (daysDifference == 0) {
      // 오늘 이미 체크인함
      return currentStreak;
    } else if (daysDifference == 1) {
      // 어제 체크인했음 - 상태 유지
      return currentStreak;
    } else if (daysDifference == 2) {
      // 하루 빠짐 - 연기로 변경
      return currentStreak.copyWith(status: StreakStatus.smoke);
    } else {
      // 2일 이상 빠짐 - 재로 변경, 스트릭 초기화
      return currentStreak.copyWith(
        currentStreak: 0,
        status: StreakStatus.ash,
      );
    }
  }

  /// 오늘 출석 체크
  Future<bool> checkIn() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 이미 오늘 체크인했는지 확인
    if (state.lastCheckInDate != null) {
      final lastCheckIn = DateTime(
        state.lastCheckInDate!.year,
        state.lastCheckInDate!.month,
        state.lastCheckInDate!.day,
      );

      if (lastCheckIn.isAtSameMomentAs(today)) {
        // 이미 오늘 체크인함
        return false;
      }

      // 어제 체크인했는지 확인
      final daysSinceLastCheckIn = today.difference(lastCheckIn).inDays;

      if (daysSinceLastCheckIn == 1) {
        // 연속 출석
        final newStreak = state.currentStreak + 1;
        StreakStatus newStatus;

        if (newStreak >= 3) {
          newStatus = StreakStatus.strongFire;
        } else if (newStreak >= 2) {
          newStatus = StreakStatus.fire;
        } else {
          newStatus = StreakStatus.ash;
        }

        state = state.copyWith(
          currentStreak: newStreak,
          longestStreak:
              newStreak > state.longestStreak ? newStreak : state.longestStreak,
          lastCheckInDate: today,
          status: newStatus,
          totalCheckIns: state.totalCheckIns + 1,
        );
      } else if (daysSinceLastCheckIn == 2) {
        // 하루 빠졌다가 다시 체크인 (연기 -> 불)
        state = state.copyWith(
          currentStreak: 1,
          lastCheckInDate: today,
          status: StreakStatus.ash,
          totalCheckIns: state.totalCheckIns + 1,
        );
      } else {
        // 2일 이상 빠짐 - 스트릭 초기화
        state = state.copyWith(
          currentStreak: 1,
          lastCheckInDate: today,
          status: StreakStatus.ash,
          totalCheckIns: state.totalCheckIns + 1,
        );
      }
    } else {
      // 첫 체크인
      state = state.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastCheckInDate: today,
        status: StreakStatus.ash,
        totalCheckIns: 1,
      );
    }

    await _persist();
    return true;
  }

  /// 스트릭 초기화
  Future<void> reset() async {
    state = StreakModel.initial();
    await _persist();
  }
}

final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakModel>((ref) {
  return StreakNotifier();
});
