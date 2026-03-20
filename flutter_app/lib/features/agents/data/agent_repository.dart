import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mandarart_journey/features/agents/domain/agent_models.dart';

abstract class AgentRepository {
  Future<List<PlatformAgent>> listAgents();
}

final agentRepositoryProvider = Provider<AgentRepository>((ref) {
  return const AssetAgentRepository();
});

final agentCatalogProvider = FutureProvider<List<PlatformAgent>>((ref) {
  return ref.watch(agentRepositoryProvider).listAgents();
});

class AssetAgentRepository implements AgentRepository {
  const AssetAgentRepository();

  @override
  Future<List<PlatformAgent>> listAgents() async {
    final raw =
        await rootBundle.loadString('assets/fixtures/agent_definitions.json');
    final decoded = jsonDecode(raw) as List<dynamic>;
    final agents = decoded
        .map((item) => PlatformAgent.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    agents.sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    return agents;
  }
}
