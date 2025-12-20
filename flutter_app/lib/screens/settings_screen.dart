import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => context.pop(),
        ),
        middle: const Text('환경설정'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            _buildSectionHeader('계정'),
            _buildAccountCard(context),
            _buildSectionHeader('데이터 관리'),
            _buildDataManagementItem('JSON 가져오기', '외부 백업 파일 복원', CupertinoIcons.folder_open, () {}),
            _buildDataManagementItem('전체 데이터 내보내기', '데이터를 파일로 백업', CupertinoIcons.archivebox, () {}),
            _buildSectionHeader('앱 정보'),
            _buildAppInfoItem('현재 버전', 'v1.2.0'),
            _buildAppInfoItem('이용약관 및 개인정보처리방침', '', isNavigation: true),
            _buildAppInfoItem('문의하기', '', isNavigation: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.secondaryLabel,
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const CupertinoListTile(
              leading: Icon(CupertinoIcons.person_alt_circle, size: 40),
              title: Text('로그인이 필요합니다'),
              subtitle: Text('데이터 백업 및 동기화 사용'),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () {},
              child: const Text('Google로 시작하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CupertinoListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(CupertinoIcons.right_chevron),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAppInfoItem(String title, String trailing, {bool isNavigation = false}) {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CupertinoListTile(
        title: Text(title),
        trailing: isNavigation
            ? const Icon(CupertinoIcons.arrow_up_right_square)
            : Text(trailing, style: const TextStyle(color: CupertinoColors.secondaryLabel)),
        onTap: isNavigation ? () {} : null,
      ),
    );
  }
}
