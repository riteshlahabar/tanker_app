import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/shell_tabs_controller.dart';
import '../models/nav_tab.dart';
import 'app_bottom_nav.dart';

/// The bottom bar, on every screen.
///
/// The shell uses it for its own tabs; a **pushed** screen uses the same
/// widget with no arguments, which is what keeps the bar identical everywhere
/// rather than one copy per screen drifting out of step. Tapping a tab from a
/// pushed screen unwinds back to the shell and lands on that tab, so the bar
/// always means the same thing — go to this section — wherever it is tapped.
/// Inside the shell the unwind is a no-op, because the shell *is* the first
/// route.
///
/// [tabs] is how the shell hands over its own list: it is mounting at that
/// moment and has not registered them yet, and reading the empty provider
/// instead would leave the shell's first frame without a bar. A pushed screen
/// leaves it null and reads the registered tabs, which by then are there.
///
/// Before sign-in there are no tabs at all, so the bar takes no space on the
/// login and splash screens.
class ShellTabBar extends ConsumerWidget {
  const ShellTabBar({super.key, this.tabs});

  final List<NavTab>? tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shell = ref.watch(shellTabsProvider);
    final tabs = this.tabs ?? shell.tabs;

    if (tabs.isEmpty) return const SizedBox.shrink();

    return AppBottomNav(
      tabs: tabs,
      currentIndex: shell.index.clamp(0, tabs.length - 1),
      onTap: (index) {
        ref.read(shellTabsProvider.notifier).select(index);

        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}
