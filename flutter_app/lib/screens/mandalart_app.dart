import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/widgets/mandalart_viewer.dart';
import 'package:mandarart_journey/widgets/step_progress_indicator.dart';
import 'package:mandarart_journey/widgets/step_arrow_button.dart';
import 'package:mandarart_journey/widgets/steps/calendar_step.dart';
import 'package:mandarart_journey/widgets/goal_input_dialog.dart';
import 'package:mandarart_journey/widgets/steps/combined_step.dart';

import 'package:responsive_builder/responsive_builder.dart';


class MandalartAppScreen extends ConsumerStatefulWidget {
  const MandalartAppScreen({super.key});

  @override
  ConsumerState<MandalartAppScreen> createState() => _MandalartAppScreenState();
}

class _MandalartAppScreenState extends ConsumerState<MandalartAppScreen> {
  late final PageController _pageController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _checkAndNavigateToViewer();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // Check if goal is empty (New User or Reset)
       if (mounted) {
         final state = ref.read(mandalartProvider);
         if (state.goalText.isEmpty) {
           showCupertinoModalPopup(
             context: context,
             builder: (_) => const GoalInputDialog(isNew: true),
           );
         }
       }
    });
  }

  Future<void> _checkAndNavigateToViewer() async {
    final prefs = await SharedPreferences.getInstance();
    final hasStarted = prefs.getBool('has_started') ?? false;

    if (hasStarted && mounted) {
      // 사용자가 이미 시작했다면 0페이지(뷰어)로 이동 (기본값이지만 명시적 설정)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(mandalartProvider.notifier).setStep(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mandalartProvider);
    final notifier = ref.read(mandalartProvider.notifier);

    // Initialize page controller with current step on first build
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(state.currentStep);
        }
      });
    }

    // Listen to step changes and animate page controller
    ref.listen<int>(
      mandalartProvider.select((value) => value.currentStep),
      (previous, next) {
        if (!_pageController.hasClients) {
          return;
        }
        final currentPage = _pageController.page?.round() ?? _pageController.initialPage;
        if (currentPage != next) {
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        }
      },
    );


    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  StepArrowButton(
                    icon: CupertinoIcons.chevron_back,
                    semanticLabel: '이전 단계로 이동',
                    onPressed: state.currentStep > 0
                        ? () {
                            HapticFeedback.lightImpact();
                            notifier.previousStep();
                          }
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: StepProgressIndicator(
                        currentStep: state.currentStep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  StepArrowButton(
                    icon: CupertinoIcons.chevron_forward,
                    semanticLabel: '다음 단계로 이동',
                    onPressed: state.currentStep < 2
                        ? () {
                            HapticFeedback.mediumImpact();
                            notifier.nextStep();
                          }
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ScreenTypeLayout.builder(
                mobile: (BuildContext context) => _buildStepPager(
                  context: context,
                  state: state,
                  notifier: notifier,
                  padding: const EdgeInsets.all(16),
                ),
                tablet: (BuildContext context) => _buildStepPager(
                  context: context,
                  state: state,
                  notifier: notifier,
                  padding: const EdgeInsets.all(32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPager({
    required BuildContext context,
    required MandalartStateModel state,
    required MandalartNotifier notifier,
    required EdgeInsets padding,
  }) {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (page) {
        if (page != state.currentStep) {
          notifier.setStep(page);
        }
      },
      children: [
        // Page 0: 만다라트 뷰어 (메인)
        MandalartViewer(
          state: state,
          withScaffold: false,
          onClose: () {
            // 편집(리스트) 페이지로 이동
            if (mounted && _pageController.hasClients) {
              notifier.setStep(1);
            }
          },
          onNavigateToActions: () {
            // 편집(리스트) 페이지로 이동
            if (mounted && _pageController.hasClients) {
              notifier.setStep(1);
            }
          },
          onShowHelp: () {
             showCupertinoModalPopup(
              context: context,
              builder: (context) => const GoalInputDialog(),
            );
          },
          onToggleAction: (themeIndex, actionIndex) {
            final newStatus = notifier.toggleActionStatus(
              themeIndex: themeIndex,
              actionIndex: actionIndex,
            );
            if (newStatus == ActionStatus.completed) {
              HapticFeedback.mediumImpact();
            }
          },
        ),
        // Page 1: 테마 + 액션 아이템 (리스트 / 편집)
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CombinedStep(state: state, notifier: notifier),
              const SizedBox(height: 32),
            ],
          ),
        ),
        // Page 2: 캘린더 (기록)
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarStep(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

}
