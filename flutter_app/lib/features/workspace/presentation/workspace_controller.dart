import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/features/auth/presentation/session_controller.dart';
import 'package:mandarart_journey/features/workspace/data/workspace_repository.dart';
import 'package:mandarart_journey/features/workspace/domain/workspace_models.dart';

class WorkspaceState {
  const WorkspaceState({
    required this.isReady,
    required this.workspaces,
    required this.activeWorkspaceId,
  });

  const WorkspaceState.initial()
      : isReady = false,
        workspaces = const [],
        activeWorkspaceId = null;

  final bool isReady;
  final List<Workspace> workspaces;
  final String? activeWorkspaceId;

  Workspace? get activeWorkspace {
    if (workspaces.isEmpty) {
      return null;
    }
    for (final workspace in workspaces) {
      if (workspace.id == activeWorkspaceId) {
        return workspace;
      }
    }
    return workspaces.first;
  }

  WorkspaceState copyWith({
    bool? isReady,
    List<Workspace>? workspaces,
    Object? activeWorkspaceId = _workspaceSentinel,
  }) {
    return WorkspaceState(
      isReady: isReady ?? this.isReady,
      workspaces: workspaces ?? this.workspaces,
      activeWorkspaceId: activeWorkspaceId == _workspaceSentinel
          ? this.activeWorkspaceId
          : activeWorkspaceId as String?,
    );
  }
}

const _workspaceSentinel = Object();

final workspaceControllerProvider =
    NotifierProvider<WorkspaceController, WorkspaceState>(
        WorkspaceController.new);

final activeWorkspaceProvider = Provider<Workspace?>((ref) {
  return ref.watch(workspaceControllerProvider).activeWorkspace;
});

final activeWorkspaceIdProvider = Provider<String?>((ref) {
  return ref.watch(workspaceControllerProvider).activeWorkspaceId;
});

class WorkspaceController extends Notifier<WorkspaceState> {
  @override
  WorkspaceState build() {
    ref.listen<SessionState>(sessionControllerProvider, (previous, next) {
      if (previous?.canAccessApp != next.canAccessApp ||
          previous?.user?.id != next.user?.id) {
        unawaited(_load(next));
      }
    });
    Future<void>(() async => _load(ref.read(sessionControllerProvider)));
    return const WorkspaceState.initial();
  }

  Future<void> _load(SessionState session) async {
    if (!session.isReady) {
      return;
    }
    if (!session.canAccessApp) {
      state = state.copyWith(
        isReady: true,
        workspaces: const [],
        activeWorkspaceId: null,
      );
      return;
    }

    final ownerUserId = session.user?.id ?? 'demo-user';
    final repository = ref.read(workspaceRepositoryProvider);
    final workspaces = await repository.ensureSeed(ownerUserId: ownerUserId);
    final storedActiveId = repository.getActiveWorkspaceId();
    final activeId =
        workspaces.any((workspace) => workspace.id == storedActiveId)
            ? storedActiveId
            : workspaces.first.id;

    if (activeId != null) {
      await repository.setActiveWorkspace(activeId);
    }

    state = state.copyWith(
      isReady: true,
      workspaces: workspaces,
      activeWorkspaceId: activeId,
    );
  }

  Future<void> setActiveWorkspace(String workspaceId) async {
    await ref.read(workspaceRepositoryProvider).setActiveWorkspace(workspaceId);
    state = state.copyWith(activeWorkspaceId: workspaceId);
  }
}
