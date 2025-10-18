import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';
import 'package:mandarart_journey/providers/theme_provider.dart';

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
    final accent = CupertinoColors.systemPurple.resolveFrom(context);
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
              const SizedBox(height: 24),
              const Hero(
                tag: 'app-title',
                child: Material(
                  color: CupertinoColors.transparent,
                  child: Text(
                    '만다라트로 여정을 디자인하세요',
                    style: TextStyle(
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
                '메이저리그 MVP 오타니 쇼헤이가 선택한 만다라트 전략으로 목표를 설계해보세요.',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _LandingHighlightCard(
                icon: CupertinoIcons.sparkles,
                title: '오타니 쇼헤이의 만다라트',
                subtitle: '고교생 시절 단 한 장으로 메이저리그 루트를 완성한 전략을 담았어요.',
                accent: accent,
              ),
              const SizedBox(height: 12),
              _LandingHighlightCard(
                icon: CupertinoIcons.square_grid_3x2_fill,
                title: '64칸 액션 플래너',
                subtitle: '목표-테마-실행을 계층적으로 정리하고 하루의 포커스를 명확히 합니다.',
                accent: accent,
              ),
              const SizedBox(height: 12),
              _LandingHighlightCard(
                icon: CupertinoIcons.scope,
                title: '감각적인 몰입 경험',
                subtitle: '퍼플 톤의 인터페이스와 인터랙션으로 진척도를 매 순간 확인하세요.',
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
                    color: CupertinoColors.systemPurple,
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
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    final name =
                        inferredName.isEmpty ? '나만의 만다라트' : inferredName;
                    ref
                        .read(mandalartProvider.notifier)
                        .updateDisplayName(name);
                    FocusScope.of(context).unfocus();
                    if (widget.isModal) {
                      Navigator.of(context).pop();
                      if (widget.onComplete != null) {
                        widget.onComplete!();
                      }
                    } else {
                      GoRouter.of(context).go('/create');
                    }
                  },
                  child: Text(
                    widget.isModal ? '확인' : '나의 만다라트 만들기',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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
          color: CupertinoColors.systemPurple,
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
        gradient: LinearGradient(
          colors: [backgroundTint, CupertinoColors.systemBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
