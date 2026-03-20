import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons, Material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mandarart_journey/l10n/app_localizations.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';
import 'package:mandarart_journey/utils/app_theme.dart';

class LandingScreen extends ConsumerStatefulWidget {
  final bool isModal;
  final VoidCallback? onComplete;

  const LandingScreen({super.key, this.isModal = false, this.onComplete});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final initialName = ref.read(mandalartProvider).displayName;
    _nameController = TextEditingController(text: initialName);
    _nameController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startJourney() async {
    HapticFeedback.mediumImpact();
    final name = _nameController.text.trim().isEmpty
        ? '나만의 만다라트'
        : _nameController.text.trim();
    ref.read(mandalartProvider.notifier).updateDisplayName(name);
    FocusScope.of(context).unfocus();

    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_started', true);

    if (!mounted) {
      return;
    }

    if (widget.isModal) {
      navigator.pop();
      widget.onComplete?.call();
      return;
    }

    router.go('/start');
  }

  void _openExamples() {
    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();
    if (widget.isModal) {
      Navigator.of(context).pop();
    }
    GoRouter.of(context).push('/example');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final themeState = ref.watch(themeProvider);
    final accent = themeState.primaryColor;
    final currentName = ref.watch(mandalartProvider).displayName;
    final inferredName = _nameController.text.trim();
    final title = currentName.isNotEmpty
        ? currentName
        : (inferredName.isNotEmpty ? inferredName : '나만의 만다라트');
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final background = CupertinoColors.systemBackground.resolveFrom(context);
    final groupedBackground =
        CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context);
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: widget.isModal ? const SizedBox.shrink() : null,
        middle: Text(title),
        backgroundColor: background.withValues(alpha: 0.92),
        border: null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorThemeButton(),
            const SizedBox(width: 8),
            _buildThemeToggleButton(),
          ],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final horizontalPadding = isWide ? 40.0 : 20.0;
            final contentWidth = isWide ? 1160.0 : 720.0;

            return Stack(
              children: [
                Positioned(
                  top: 32,
                  left: -48,
                  child: _BackdropOrb(
                    size: 180,
                    color: accent.withValues(alpha: 0.14),
                  ),
                ),
                Positioned(
                  top: 96,
                  right: isWide ? 120 : -40,
                  child: const _BackdropOrb(
                    size: 150,
                    color: AppTheme.butterLight,
                  ),
                ),
                Positioned(
                  bottom: 32,
                  right: -60,
                  child: _BackdropOrb(
                    size: 220,
                    color: AppTheme.powderBlue.withValues(alpha: 0.45),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    28,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _buildIntroColumn(
                                    context,
                                    localizations,
                                    accent,
                                    secondary,
                                    isDark,
                                  ),
                                ),
                                const SizedBox(width: 28),
                                Expanded(
                                  flex: 5,
                                  child: _buildQuickStartPanel(
                                    context,
                                    accent,
                                    groupedBackground,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildIntroColumn(
                                  context,
                                  localizations,
                                  accent,
                                  secondary,
                                  isDark,
                                ),
                                const SizedBox(height: 24),
                                _buildQuickStartPanel(
                                  context,
                                  accent,
                                  groupedBackground,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroColumn(
    BuildContext context,
    AppLocalizations localizations,
    Color accent,
    Color secondary,
    bool isDark,
  ) {
    final labelColor = CupertinoColors.label.resolveFrom(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Hero(
                tag: 'app-icon',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.24),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Hero(
                tag: 'app-name',
                child: Material(
                  color: CupertinoColors.transparent,
                  child: Text(
                    'Mandarat',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Hero(
          tag: 'app-title',
          child: Material(
            color: CupertinoColors.transparent,
            child: Text(
              localizations.landingTitle,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.4,
                height: 1.08,
                color: labelColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          localizations.landingSubtitle,
          style: TextStyle(
            fontSize: 18,
            height: 1.55,
            fontWeight: FontWeight.w600,
            color: secondary,
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _LandingMetricChip(
              icon: Icons.grid_view_rounded,
              label: '8개 핵심 주제',
              accent: accent,
            ),
            const _LandingMetricChip(
              icon: CupertinoIcons.checkmark_alt_circle_fill,
              label: '64개 실행칸',
              accent: AppTheme.butterLight,
              iconColor: AppTheme.textMainLight,
            ),
            _LandingMetricChip(
              icon: CupertinoIcons.calendar,
              label: '진행 기록 캘린더',
              accent: accent.withValues(alpha: 0.18),
              iconColor: accent,
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? CupertinoColors.systemIndigo.darkColor.withValues(alpha: 0.14)
                : AppTheme.powderBlue.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: accent.withValues(alpha: 0.18),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '만다라트는 이렇게 이어집니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: CupertinoColors.label,
                ),
              ),
              SizedBox(height: 14),
              _LandingFlowStep(
                number: '01',
                title: '목표를 하나 정합니다',
                subtitle: '핵심 목표를 쓰면 8개의 주제를 쪼개서 생각할 수 있습니다.',
              ),
              SizedBox(height: 12),
              _LandingFlowStep(
                number: '02',
                title: '실행칸으로 바로 내려갑니다',
                subtitle: '막연한 목표가 아니라 오늘 할 수 있는 행동으로 바뀝니다.',
              ),
              SizedBox(height: 12),
              _LandingFlowStep(
                number: '03',
                title: '실행과 기록을 반복합니다',
                subtitle: '진행 상태와 캘린더 기록이 한 흐름으로 연결됩니다.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _LandingHighlightCard(
              icon: CupertinoIcons.scope,
              title: '구체적으로 쓰기',
              subtitle: '형용사보다 숫자와 기준을 넣으면 다음 단계가 쉬워집니다.',
              accent: accent,
            ),
            const _LandingHighlightCard(
              icon: CupertinoIcons.chart_bar_alt_fill,
              title: '측정 가능한 목표',
              subtitle: '실행 여부가 보이는 목표일수록 체크와 기록이 분명해집니다.',
              accent: AppTheme.butterLight,
            ),
            _LandingHighlightCard(
              icon: CupertinoIcons.repeat,
              title: '매일의 루틴으로 쪼개기',
              subtitle: '이상적인 계획보다 오늘 당장 할 행동으로 바꾸는 것이 핵심입니다.',
              accent: accent.withValues(alpha: 0.22),
            ),
            _LandingHighlightCard(
              icon: CupertinoIcons.flame_fill,
              title: '습관화까지 이어가기',
              subtitle: '작은 실행과 완료 기록을 쌓아 여정을 끊기지 않게 만듭니다.',
              accent: isDark
                  ? AppTheme.primaryDark.withValues(alpha: 0.22)
                  : const Color(0xFFFFF3B2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStartPanel(
    BuildContext context,
    Color accent,
    Color groupedBackground,
  ) {
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final previewName = _nameController.text.trim().isEmpty
        ? '나만의 만다라트'
        : _nameController.text.trim();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: accent.withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.14),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  CupertinoIcons.sparkles,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '바로 시작하기',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '이름을 정하고 다음 화면에서 핵심 목표를 입력하면 바로 만다라트를 만들 수 있습니다.',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: secondary,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: groupedBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '여정 이름',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: secondary,
                  ),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: '예: 2026년 건강 루틴',
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.18),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                  placeholderStyle: TextStyle(
                    fontSize: 17,
                    color: secondary,
                  ),
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Icon(
                      CupertinoIcons.pencil_outline,
                      size: 18,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '비워두면 기본 이름인 "나만의 만다라트"로 시작합니다.',
                  style: TextStyle(
                    fontSize: 13,
                    color: secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '미리보기',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  previewName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '다음 화면에서 중심 목표와 추천 키워드를 바로 입력할 수 있습니다.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 18),
              onPressed: _startJourney,
              child: Text(
                widget.isModal ? '확인' : '나의 만다라트 만들기',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(18),
              onPressed: _openExamples,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.folder,
                    size: 18,
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '만다라트 예시보기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '저장은 로컬에서 바로 시작됩니다. 로그인이나 동기화 없이 먼저 써볼 수 있습니다.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorThemeButton() {
    final themeState = ref.watch(themeProvider);
    final primaryColor = themeState.primaryColor;

    return Semantics(
      label: 'Select color theme',
      button: true,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.lightImpact();
          _showColorThemePicker();
        },
        child: Icon(
          CupertinoIcons.color_filter,
          color: primaryColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildThemeToggleButton() {
    final themeState = ref.watch(themeProvider);
    final primaryColor = themeState.primaryColor;
    final isLight = themeState.mode == AppThemeMode.light;
    final icon =
        isLight ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill;
    final label = isLight ? 'Light mode' : 'Dark mode';

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
          color: primaryColor,
          size: 24,
        ),
      ),
    );
  }

  void _showColorThemePicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text(
          '색상 테마 선택',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        message: const Text('앱 전체의 강조 색상을 선택하세요'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(themeProvider.notifier).setColorTheme(ColorTheme.green);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('녹색'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(themeProvider.notifier).setColorTheme(ColorTheme.purple);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemPurple,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('보라색'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(themeProvider.notifier).setColorTheme(ColorTheme.black);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: CupertinoColors.black,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CupertinoColors.systemGrey,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('검은색'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(themeProvider.notifier).setColorTheme(ColorTheme.white);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CupertinoColors.systemGrey,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('흰색'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ),
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  const _BackdropOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 48,
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingMetricChip extends StatelessWidget {
  const _LandingMetricChip({
    required this.icon,
    required this.label,
    required this.accent,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final labelColor = CupertinoColors.label.resolveFrom(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              icon,
              size: 15,
              color: iconColor ?? CupertinoColors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingFlowStep extends StatelessWidget {
  const _LandingFlowStep({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final String number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final primary = CupertinoTheme.of(context).primaryColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            number,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LandingHighlightCard extends StatelessWidget {
  const _LandingHighlightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: accent.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground
                    .resolveFrom(context)
                    .withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: CupertinoColors.label.resolveFrom(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
