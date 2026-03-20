import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/features/chat/domain/conversation_models.dart';
import 'package:mandarart_journey/features/projects/data/project_repository.dart';

class ExecutionLog {
  const ExecutionLog({
    required this.conversation,
    required this.messages,
    required this.toolRuns,
  });

  final ExecutionConversation conversation;
  final List<ExecutionMessage> messages;
  final List<ToolRun> toolRuns;
}

abstract class ConversationRepository {
  Future<ExecutionLog?> getExecutionLog(String projectId);
}

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ProjectConversationRepository(ref.watch(projectRepositoryProvider));
});

final executionLogProvider =
    FutureProvider.family<ExecutionLog?, String>((ref, projectId) async {
  return ref.watch(conversationRepositoryProvider).getExecutionLog(projectId);
});

class ProjectConversationRepository implements ConversationRepository {
  const ProjectConversationRepository(this._projectRepository);

  final ProjectRepository _projectRepository;

  @override
  Future<ExecutionLog?> getExecutionLog(String projectId) async {
    final bundle = await _projectRepository.getProject(projectId);
    if (bundle == null) {
      return null;
    }
    return ExecutionLog(
      conversation: bundle.conversation,
      messages: bundle.messages,
      toolRuns: bundle.toolRuns,
    );
  }
}
