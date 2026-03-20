import 'package:mandarart_journey/models/mandalart.dart';

class GridCell {
  final String? text;
  final String type; // goal | theme | outer-theme | action | empty
  final ActionStatus status;
  final int? themeIndex;
  final int? actionIndex;
  const GridCell({
    this.text,
    required this.type,
    this.status = ActionStatus.notStarted,
    this.themeIndex,
    this.actionIndex,
  });

  // 하위 호환성을 위한 getter
  bool get isCompleted => status == ActionStatus.completed;
  bool get isInProgress => status == ActionStatus.inProgress;
  bool get isNotStarted => status == ActionStatus.notStarted;
}

List<List<GridCell>> createMandalartGrid(MandalartStateModel state) {
  final grid = List.generate(
      9, (_) => List.generate(9, (_) => const GridCell(type: 'empty')));

  grid[4][4] = GridCell(text: state.goalText, type: 'goal');

  final themePositions = <List<int>>[
    [3, 3],
    [3, 4],
    [3, 5],
    [4, 3],
    [4, 5],
    [5, 3],
    [5, 4],
    [5, 5],
  ];

  final outerThemeCenters = <List<int>>[
    [1, 1],
    [1, 4],
    [1, 7],
    [4, 1],
    [4, 7],
    [7, 1],
    [7, 4],
    [7, 7],
  ];

  List<List<int>> actionPositionsFor(int themeIndex) {
    const pos = [
      // 0: top-left
      [0, 0], [0, 1], [0, 2], [1, 0], [1, 2], [2, 0], [2, 1], [2, 2],
      // 1: top-center
      [0, 3], [0, 4], [0, 5], [1, 3], [1, 5], [2, 3], [2, 4], [2, 5],
      // 2: top-right
      [0, 6], [0, 7], [0, 8], [1, 6], [1, 8], [2, 6], [2, 7], [2, 8],
      // 3: middle-left
      [3, 0], [3, 1], [3, 2], [4, 0], [4, 2], [5, 0], [5, 1], [5, 2],
      // 4: middle-right
      [3, 6], [3, 7], [3, 8], [4, 6], [4, 8], [5, 6], [5, 7], [5, 8],
      // 5: bottom-left
      [6, 0], [6, 1], [6, 2], [7, 0], [7, 2], [8, 0], [8, 1], [8, 2],
      // 6: bottom-center
      [6, 3], [6, 4], [6, 5], [7, 3], [7, 5], [8, 3], [8, 4], [8, 5],
      // 7: bottom-right
      [6, 6], [6, 7], [6, 8], [7, 6], [7, 8], [8, 6], [8, 7], [8, 8],
    ];
    final start = themeIndex * 8;
    return List.generate(8, (i) => pos[start + i]);
  }

  // UPDATED: access .themeText
  final filledThemes =
      state.themes.where((t) => t.themeText.trim().isNotEmpty).toList();

  for (var i = 0; i < filledThemes.length && i < 8; i++) {
    final tText = filledThemes[i].themeText;
    final tp = themePositions[i];
    grid[tp[0]][tp[1]] = GridCell(text: tText, type: 'theme', themeIndex: i);

    final oc = outerThemeCenters[i];
    grid[oc[0]][oc[1]] =
        GridCell(text: tText, type: 'outer-theme', themeIndex: i);

    final themeId = 'theme-$i';
    final actions = state.actionItems
        .where((a) => a.themeId == themeId)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final apos = actionPositionsFor(i);
    for (var j = 0; j < actions.length && j < 8; j++) {
      final a = actions[j];
      final p = apos[j];
      grid[p[0]][p[1]] = GridCell(
        text: a.actionText,
        type: 'action',
        status: a.status,
        themeIndex: i,
        actionIndex: a.order,
      );
    }
  }

  return grid;
}

List<List<GridCell>> createThemeGrid(
    MandalartStateModel state, int themeIndex) {
  final grid = List.generate(
      3, (_) => List.generate(3, (_) => const GridCell(type: 'empty')));
  // UPDATED: access .themeText
  final themes =
      state.themes.where((t) => t.themeText.trim().isNotEmpty).toList();
  if (themeIndex < 0 || themeIndex >= themes.length) return grid;

  grid[1][1] = GridCell(
      text: themes[themeIndex].themeText,
      type: 'theme',
      themeIndex: themeIndex);
  final themeId = 'theme-$themeIndex';
  final actions = state.actionItems.where((a) => a.themeId == themeId).toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  const positions = <List<int>>[
    [0, 0],
    [0, 1],
    [0, 2],
    [1, 0],
    [1, 2],
    [2, 0],
    [2, 1],
    [2, 2]
  ];

  for (var i = 0; i < actions.length && i < 8; i++) {
    final p = positions[i];
    final a = actions[i];
    grid[p[0]][p[1]] = GridCell(
      text: a.actionText,
      type: 'action',
      status: a.status,
      themeIndex: themeIndex,
      actionIndex: a.order,
    );
  }
  return grid;
}
