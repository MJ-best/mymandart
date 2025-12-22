import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandarart_journey/providers/mandalart_provider.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF9FABBE) 
            : const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildKeywordChip(BuildContext context, String emoji, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        _goalController.text = label;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2B1B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(BuildContext context, bool isGood, String label, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isGood 
                ? (isDark ? const Color(0xFF1E3A2F) : const Color(0xFFDCFCE7))
                : (isDark ? const Color(0xFF3F1D1D) : const Color(0xFFFEE2E2)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isGood 
                  ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534))
                  : (isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 100), // Top padding for header space
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                const SizedBox(height: 12),
                Text(
                  '어떤 목표를\n이루고 싶으신가요?',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: colorScheme.onSurface,
                     letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '성공적인 계획을 위해 핵심 주제를 입력해주세요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    color: isDark ? const Color(0xFF9FABBE) : const Color(0xFF8E8E93), // Muted text
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                // Inputs
                _buildLabel(context, '만다라트 이름'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface, fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surface,
                      hintText: '예: 2024년 갓생 프로젝트',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16), // Rounded-2xl
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2), // Ring effect
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildLabel(context, '중심 주제 (최종 목표)'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: TextField(
                    controller: _goalController,
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface, fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surface,
                      hintText: '예: 바디프로필 촬영 성공',
                      hintStyle: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3)
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Keywords
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    '추천 목표 키워드',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF9FABBE) : const Color(0xFF8E8E93),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      _buildKeywordChip(context, '💼', '이직 성공'),
                      const SizedBox(width: 8),
                      _buildKeywordChip(context, '💪', '체지방 15%'),
                      const SizedBox(width: 8),
                      _buildKeywordChip(context, '✈️', '유럽 여행'),
                      const SizedBox(width: 8),
                      _buildKeywordChip(context, '📚', '책 50권'),
                    ],
                  ),
                ),
                 const SizedBox(height: 32),

                // Guide Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2B1B) : Colors.white, // Surface Dark from Design
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                       color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.lightbulb, size: 16, color: primaryColor),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '작성 가이드',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '중심 주제는 구체적이고 측정 가능할수록 좋습니다.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF9FABBE) : const Color(0xFF8E8E93),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildGuideItem(context, false, 'Bad', '그냥 부자 되기'),
                            const SizedBox(height: 8),
                            _buildGuideItem(context, true, 'Good', '올해 1,000만원 모으기'),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
          
          // Sticky Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                   color: colorScheme.surface.withValues(alpha: 0.85), // Slightly transparent background to let blur show through
                   child: SafeArea(
                     bottom: false,
                     child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                           color: Colors.transparent, // Ensure container itself is transparent
                           border: Border(bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.black.withValues(alpha:0.05)))
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                             Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () => context.pop(),
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                   alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      )
                                    ]
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 18,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '만다라트 만들기',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                     ),
                   ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 48,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_goalController.text.trim().isEmpty) {
                // Shake or error
                HapticFeedback.heavyImpact();
                return;
              }
              HapticFeedback.mediumImpact();
              // Create Mandalart
              ref.read(mandalartProvider.notifier).initialize(
                _titleController.text.isEmpty ? '나의 만다라트' : _titleController.text,
                _goalController.text,
              );
              context.go('/app');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
              shadowColor: primaryColor.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '시작하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
