import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarart_journey/models/mandalart.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';
import 'package:mandarart_journey/widgets/mandalart_viewer.dart';
import 'package:mandarart_journey/widgets/step_progress_indicator.dart';
import 'package:mandarart_journey/widgets/step_arrow_button.dart';
import 'package:mandarart_journey/widgets/steps/goal_step.dart';
import 'package:mandarart_journey/widgets/steps/themes_step.dart';
import 'package:mandarart_journey/widgets/steps/actions_step.dart';
import 'package:mandarart_journey/screens/landing_screen.dart';
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

    // Listen to viewer state changes to update page controller
    ref.listen<bool>(
      mandalartProvider.select((value) => value.showViewer),
      (previous, next) {
        // Viewer가 닫힐 때 (true -> false) PageController를 현재 step으로 업데이트
        if (previous == true && next == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _pageController.hasClients) {
              _pageController.jumpToPage(state.currentStep);
            }
          });
        }
      },
    );

    if (state.showViewer) {
      return MandalartViewer(
        state: state,
        onClose: notifier.closeViewer,
        onNavigateToActions: () {
          // 뷰어 닫고 Page 2 (액션 아이템 페이지)로 이동
          notifier.closeViewer();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && _pageController.hasClients) {
              notifier.setStep(2);
            }
          });
        },
        onToggleAction: (themeIndex, actionIndex) {
          notifier.toggleActionStatus(
            themeIndex: themeIndex,
            actionIndex: actionIndex,
          );
        },
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: state.currentStep > 0
            ? CupertinoNavigationBarBackButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  notifier.previousStep();
                },
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _showHelpModal(context);
                },
                child: const Icon(CupertinoIcons.question_circle),
              ),
        middle: Text(
          state.displayName.isNotEmpty ? state.displayName : '나만의 만다라트',
        ),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeToggleButton(ref),
            const SizedBox(width: 8),
            Semantics(
              label: 'View Mandalart grid',
              button: true,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  notifier.openViewer();
                },
                child: const Icon(CupertinoIcons.square_grid_2x2),
              ),
            ),
          ],
        ),
      ),
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
                    semanticLabel: state.currentStep < 2
                        ? '다음 단계로 이동'
                        : '만다라트 보기 열기',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (state.currentStep < 2) {
                        notifier.nextStep();
                      } else {
                        notifier.openViewer();
                      }
                    },
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
      children: List.generate(3, (index) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index == 0)
                GoalStep(
                  value: state.goalText,
                  onChange: notifier.updateGoal,
                )
              else if (index == 1)
                ThemesStep(
                  goalText: state.goalText,
                  themes: state.themes,
                  onChange: notifier.updateThemes,
                )
              else
                ActionsStep(state: state, notifier: notifier),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  void _showHelpModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const LandingScreen(isModal: true),
    );
  }

  Widget _buildThemeToggleButton(WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final bool isLight = themeState.mode == ThemeMode.light;
    final IconData icon = isLight ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill;
    final String label = isLight ? 'Light mode' : 'Dark mode';

    return Semantics(
      label: 'Toggle theme: $label',
      button: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.lightImpact();
          ref.read(themeProvider.notifier).toggleTheme();
        },
        child: Icon(
          icon,
          color: CupertinoColors.systemPurple,
          size: 24,
        ),
      ),
    );
  }
}
