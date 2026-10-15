import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/nav_tab.dart';
import 'app_bottom_nav.dart';

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
/// A drawer is passed in only by the admin shell; driver and customer shells
/// leave it null and so have none.
class RoleShell extends StatefulWidget {
  const RoleShell({
    super.key,
    required this.tabs,
    this.drawer,
  });

  final List<NavTab> tabs;
  final Widget? drawer;

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _index = 0;

  bool get _onHomeTab => _index == 0;

  Future<void> _handleBack() async {
    if (!_onHomeTab) {
      setState(() => _index = 0);

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
    final tab = widget.tabs[_index];

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
          index: _index,
          children: widget.tabs.map((t) => t.body).toList(growable: false),
        ),
        bottomNavigationBar: AppBottomNav(
          tabs: widget.tabs,
          currentIndex: _index,
          onTap: (index) => setState(() => _index = index),
        ),
      ),
    );
  }
}
