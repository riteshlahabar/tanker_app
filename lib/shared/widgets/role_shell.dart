import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/shell_tabs_controller.dart';
import '../models/nav_tab.dart';
import 'shell_tab_bar.dart';

/// The root route for a signed-in role: an app bar, the tab bodies in an
/// IndexedStack, and the bottom bar.
///
/// Three navigation rules the owner asked for are enforced here rather than
/// screen by screen:
///
///  * the shell is the only root route, so a pushed detail screen always pops
///    back to the screen immediately behind it and never skips further;
///  * hardware back on a tab other than the first returns to the first tab;
///  * hardware back on the first tab asks before leaving the app.
///
/// Which tab is selected lives in [shellTabsProvider] rather than in this
/// State, so a pushed screen can draw the same bar and move the shell with it
/// — the owner asked for the bar on every screen, not only on the shell.
///
/// A drawer is passed in only by the admin shell; driver and customer shells
/// leave it null and so have none.
class RoleShell extends ConsumerStatefulWidget {
  const RoleShell({
    super.key,
    required this.tabs,
    this.drawer,
  });

  final List<NavTab> tabs;
  final Widget? drawer;

  @override
  ConsumerState<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends ConsumerState<RoleShell> {
  @override
  void initState() {
    super.initState();

    // Registered here rather than in build: writing a provider's state while
    // building is the fault that left every screen spinning once already.
    Future<void>.microtask(
      () => ref.read(shellTabsProvider.notifier).register(widget.tabs),
    );
  }

  Future<void> _handleBack() async {
    if (!ref.read(shellTabsProvider).onHomeTab) {
      ref.read(shellTabsProvider.notifier).goHome();

      return;
    }

    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave the app?'),
        content: const Text('Do you want to close Tanker?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    // SystemNavigator rather than Navigator.pop: popping the root route would
    // re-enter this same PopScope and never actually leave.
    if (leave ?? false) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // The provider is empty for the first frame, before initState's microtask
    // has run, so the widget's own tabs are what this reads.
    final index = ref.watch(shellTabsProvider).index.clamp(0, widget.tabs.length - 1);
    final tab = widget.tabs[index];

    return PopScope(
      // Never let the framework pop the shell itself; _handleBack decides.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_handleBack());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tab.title),
          actions: tab.actions,
        ),
        drawer: widget.drawer,
        body: IndexedStack(
          index: index,
          children: widget.tabs.map((t) => t.body).toList(growable: false),
        ),
        bottomNavigationBar: ShellTabBar(tabs: widget.tabs),
      ),
    );
  }
}
