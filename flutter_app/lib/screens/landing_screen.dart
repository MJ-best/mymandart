import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';
import 'package:mandarart_journey/l10n/app_localizations.dart';

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
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentName = ref.watch(mandalartProvider).displayName;
    final inferredName = _nameController.text.trim();
    final title = currentName.isNotEmpty
        ? currentName
        : (inferredName.isNotEmpty ? inferredName : '나만의 만다라트');
    final accent = CupertinoColors.systemGreen.resolveFrom(context);
    final secondary = CupertinoColors.secondaryLabel.resolveFrom(context);
    final iconShadow = accent.withAlpha((0.35 * 255).round());

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: widget.isModal ? const SizedBox.shrink() : null,
        middle: Text(title),
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        trailing: _buildThemeToggleButton(),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Column(
                children: [
                  Hero(
                    tag: 'app-icon',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: iconShadow,
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Hero(
                    tag: 'app-name',
                    child: Material(
                      color: CupertinoColors.transparent,
                      child: Text(
                        'Mandarat',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: accent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Hero(
                tag: 'app-title',
                child: Material(
                  color: CupertinoColors.transparent,
                  child: Text(
                    AppLocalizations.of(context)!.landingTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.2,
                      color: CupertinoColors.label,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.landingSubtitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _LandingHighlightCard(
                icon: CupertinoIcons.exclamationmark_triangle,
                title: '형용사 사용금지',
                subtitle: '운동열심히하기 ✗ → RSQ 130kg 달성하기 ✓\n측정 가능한 구체적 목표를 설정하세요.',
                accent: accent,
              ),
              const SizedBox(height: 12),
              _LandingHighlightCard(
                icon: CupertinoIcons.chart_bar_alt_fill,
                title: '측정가능한 지표 설정',
                subtitle: '밥 10그릇 먹기처럼 명확하게 측정할 수 있는\n숫자와 단위를 포함하세요.',
                accent: accent,
              ),
              const SizedBox(height: 12),
              _LandingHighlightCard(
                icon: CupertinoIcons.repeat,
                title: '일상 루틴으로 통합',
                subtitle: '운을 키우기 ✗ → 매일 쓰레기 줍기 ✓\n매일 실행할 수 있는 구체적 행동으로 만드세요.',
                accent: accent,
              ),
              const SizedBox(height: 12),
              _LandingHighlightCard(
                icon: CupertinoIcons.flame_fill,
                title: '66일 습관화 법칙',
                subtitle: '21일 의식적 실행 단계를 거쳐\n66일 무의식 습관화 단계로 나아가세요.',
                accent: accent,
              ),
              const SizedBox(height: 36),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '앱에서 당신의 여정을 어떻게 부를까요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _nameController,
                placeholder: '예: 나의 메이저리그 여정',
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                style: const TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.label,
                ),
                placeholderStyle: const TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.secondaryLabel,
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(
                    CupertinoIcons.pencil_outline,
                    color: CupertinoColors.systemGreen,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Semantics(
                label: 'Start creating your Mandalart',
                button: true,
                child: CupertinoButton.filled(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    final name =
                        inferredName.isEmpty ? '나만의 만다라트' : inferredName;
                    ref
                        .read(mandalartProvider.notifier)
                        .updateDisplayName(name);
                    FocusScope.of(context).unfocus();

                    // Capture context before async gap
                    final navigator = Navigator.of(context);
                    final router = GoRouter.of(context);

                    // 사용자가 시작했음을 기록
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_started', true);

                    if (!mounted) return;
                    if (widget.isModal) {
                      navigator.pop();
                      if (widget.onComplete != null) {
                        widget.onComplete!();
                      }
                    } else {
                      router.go('/create');
                    }
                  },
                  child: Text(
                    widget.isModal ? '확인' : '나의 만다라트 만들기',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'View saved Mandalarts',
                button: true,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CupertinoColors.systemGreen.resolveFrom(context),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      FocusScope.of(context).unfocus();
                      if (widget.isModal) {
                        Navigator.of(context).pop();
                      }
                      GoRouter.of(context).push('/example');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.folder,
                          size: 20,
                          color: CupertinoColors.systemGreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '만다라트 예시보기',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label.resolveFrom(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 다크모드 토글 버튼
  Widget _buildThemeToggleButton() {
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
          color: CupertinoColors.systemGreen,
          size: 24,
        ),
      ),
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
    final backgroundTint = accent.withAlpha((0.16 * 255).round());
    final borderTint = accent.withAlpha((0.18 * 255).round());

    return Container(
      decoration: BoxDecoration(
        color: backgroundTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderTint),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: CupertinoColors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
