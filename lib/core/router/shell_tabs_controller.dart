import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/models/nav_tab.dart';

part 'shell_tabs_controller.g.dart';

/// Which tab of the signed-in role's shell is selected, and the tabs
/// themselves.
///
/// This lives outside the shell because the owner asked for the bottom bar on
/// *every* screen, pushed detail screens included — and a pushed route is a
/// sibling of the shell in the root navigator, not a descendant of its
/// subtree, so it cannot reach the shell's own State or an InheritedWidget.
/// Holding the selection here keeps one source of truth: the bar a pushed
/// screen draws highlights the same tab the shell is on, and tapping it moves
/// the shell rather than opening a second copy of a tab.
class ShellTabsState {
  const ShellTabsState({this.tabs = const [], this.index = 0});

  final List<NavTab> tabs;
  final int index;

  bool get onHomeTab => index == 0;
}

@Riverpod(keepAlive: true)
class ShellTabs extends _$ShellTabs {
  @override
  ShellTabsState build() => const ShellTabsState();

  /// Called by the shell as it mounts. Signing in as another role replaces the
  /// tabs and starts again on the home tab.
  void register(List<NavTab> tabs) => state = ShellTabsState(tabs: tabs);

  void select(int index) => state = ShellTabsState(tabs: state.tabs, index: index);

  /// Select a tab by the label its [NavTab] carries, ignoring the call when no
  /// such tab is registered. Lets a screen send the owner to a sibling tab —
  /// the dashboard's "All orders", say — without hard-coding an index that a
  /// later tab reshuffle would silently break.
  void selectLabel(String label) {
    final index = state.tabs.indexWhere((tab) => tab.label == label);

    if (index >= 0) select(index);
  }

  /// Hardware back on a tab other than the home one returns to it.
  void goHome() => select(0);
}
