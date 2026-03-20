import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:mandarart_journey/core/providers/app_providers.dart';
import 'package:mandarart_journey/features/workspace/domain/workspace_models.dart';

abstract class WorkspaceRepository {
  Future<List<Workspace>> ensureSeed({required String ownerUserId});
  Future<void> setActiveWorkspace(String workspaceId);
  String? getActiveWorkspaceId();
}

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return LocalWorkspaceRepository(ref.watch(sharedPreferencesProvider));
});

class LocalWorkspaceRepository implements WorkspaceRepository {
  LocalWorkspaceRepository(this._prefs);

  static const _workspacesKey = 'platform.workspaces';
  static const _activeWorkspaceKey = 'platform.active_workspace_id';

  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  @override
  Future<List<Workspace>> ensureSeed({required String ownerUserId}) async {
    final current = _read(ownerUserId);
    if (current.isNotEmpty) {
      return current;
    }

    final now = DateTime.now();
    final workspace = Workspace(
      id: _uuid.v4(),
      ownerUserId: ownerUserId,
      name: ownerUserId == 'demo-user' ? 'Demo Studio' : 'My Workspace',
      slug: ownerUserId == 'demo-user' ? 'demo-studio' : 'my-workspace',
      plan: 'free',
      createdAt: now,
      updatedAt: now,
    );

    await _prefs.setString(_workspacesKey, jsonEncode([workspace.toJson()]));
    await setActiveWorkspace(workspace.id);
    return [workspace];
  }

  @override
  String? getActiveWorkspaceId() {
    return _prefs.getString(_activeWorkspaceKey);
  }

  @override
  Future<void> setActiveWorkspace(String workspaceId) async {
    await _prefs.setString(_activeWorkspaceKey, workspaceId);
  }

  List<Workspace> _read(String ownerUserId) {
    final raw = _prefs.getString(_workspacesKey);
    if (raw == null || raw.isEmpty) {
      return <Workspace>[];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Workspace.fromJson(item as Map<String, dynamic>))
        .where((workspace) => workspace.ownerUserId == ownerUserId)
        .toList(growable: false);
  }
}
