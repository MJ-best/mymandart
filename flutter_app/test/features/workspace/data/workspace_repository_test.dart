import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mandarart_journey/features/workspace/data/workspace_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ensureSeed creates and selects a demo workspace', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalWorkspaceRepository(prefs);

    final workspaces = await repository.ensureSeed(ownerUserId: 'demo-user');

    expect(workspaces, hasLength(1));
    expect(workspaces.first.name, 'Demo Studio');
    expect(repository.getActiveWorkspaceId(), workspaces.first.id);
  });

  test('ensureSeed reuses stored workspace for the same owner', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = LocalWorkspaceRepository(prefs);

    final first = await repository.ensureSeed(ownerUserId: 'owner-1');
    final second = await repository.ensureSeed(ownerUserId: 'owner-1');

    expect(second, hasLength(1));
    expect(second.first.id, first.first.id);
    expect(second.first.name, 'My Workspace');
  });
}
