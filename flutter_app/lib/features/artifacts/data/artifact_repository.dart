import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/features/artifacts/domain/artifact_models.dart';
import 'package:mandarart_journey/features/projects/data/project_repository.dart';

class ArtifactRequest {
  const ArtifactRequest({
    required this.projectId,
    required this.artifactId,
  });

  final String projectId;
  final String artifactId;
}

abstract class ArtifactRepository {
  Future<List<ProjectArtifact>> listArtifacts(String projectId);
  Future<ProjectArtifact?> getArtifact({
    required String projectId,
    required String artifactId,
  });
}

final artifactRepositoryProvider = Provider<ArtifactRepository>((ref) {
  return ProjectArtifactRepository(ref.watch(projectRepositoryProvider));
});

final projectArtifactsProvider =
    FutureProvider.family<List<ProjectArtifact>, String>(
        (ref, projectId) async {
  return ref.watch(artifactRepositoryProvider).listArtifacts(projectId);
});

final artifactProvider =
    FutureProvider.family<ProjectArtifact?, ArtifactRequest>(
  (ref, request) async {
    return ref.watch(artifactRepositoryProvider).getArtifact(
          projectId: request.projectId,
          artifactId: request.artifactId,
        );
  },
);

class ProjectArtifactRepository implements ArtifactRepository {
  const ProjectArtifactRepository(this._projectRepository);

  final ProjectRepository _projectRepository;

  @override
  Future<ProjectArtifact?> getArtifact({
    required String projectId,
    required String artifactId,
  }) async {
    final bundle = await _projectRepository.getProject(projectId);
    if (bundle == null) {
      return null;
    }
    for (final artifact in bundle.artifacts) {
      if (artifact.id == artifactId) {
        return artifact;
      }
    }
    return null;
  }

  @override
  Future<List<ProjectArtifact>> listArtifacts(String projectId) async {
    final bundle = await _projectRepository.getProject(projectId);
    return bundle?.artifacts ?? const [];
  }
}
