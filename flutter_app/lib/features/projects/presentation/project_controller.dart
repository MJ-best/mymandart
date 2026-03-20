import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/features/agents/data/agent_repository.dart';
import 'package:mandarart_journey/features/auth/presentation/session_controller.dart';
import 'package:mandarart_journey/features/projects/data/project_repository.dart';
import 'package:mandarart_journey/features/projects/domain/project_models.dart';
import 'package:mandarart_journey/features/workspace/presentation/workspace_controller.dart';

class ProjectComposerState {
  const ProjectComposerState({
    required this.isSubmitting,
    this.errorMessage,
  });

  const ProjectComposerState.initial()
      : isSubmitting = false,
        errorMessage = null;

  final bool isSubmitting;
  final String? errorMessage;

  ProjectComposerState copyWith({
    bool? isSubmitting,
    Object? errorMessage = _projectSentinel,
  }) {
    return ProjectComposerState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == _projectSentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _projectSentinel = Object();

final projectBundlesProvider = FutureProvider<List<ProjectBundle>>((ref) async {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  if (workspaceId == null) {
    return const [];
  }
  return ref
      .watch(projectRepositoryProvider)
      .listProjects(workspaceId: workspaceId);
});

final projectBundleProvider =
    FutureProvider.family<ProjectBundle?, String>((ref, projectId) async {
  return ref.watch(projectRepositoryProvider).getProject(projectId);
});

final projectComposerControllerProvider =
    NotifierProvider<ProjectComposerController, ProjectComposerState>(
  ProjectComposerController.new,
);

class ProjectComposerController extends Notifier<ProjectComposerState> {
  @override
  ProjectComposerState build() {
    return const ProjectComposerState.initial();
  }

  Future<ProjectBundle?> createProjectFromGoal(String goal) async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null) {
      state = state.copyWith(errorMessage: 'No active workspace is available.');
      return null;
    }

    final session = ref.read(sessionControllerProvider);
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final agents = await ref.read(agentRepositoryProvider).listAgents();
      final project =
          await ref.read(projectRepositoryProvider).createProjectFromGoal(
                workspaceId: workspaceId,
                createdBy: session.user?.id ?? 'demo-user',
                projectGoal: goal,
                agents: agents,
              );
      ref.invalidate(projectBundlesProvider);
      ref.invalidate(projectBundleProvider(project.project.id));
      return project;
    } on ProjectRepositoryException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return null;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
