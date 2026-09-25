import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myexpence/core/widgets/draggable_floating_action_button.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class MainShellScreen extends StatefulWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  StreamSubscription? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initSharedIntentListener();
  }

  void _initSharedIntentListener() {
    try {
      // For sharing images/files while app is running/backgrounded
      _intentDataStreamSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
        if (value.isNotEmpty && mounted) {
          final sharedPath = value.first.path;
          context.push('/share-receipt', extra: sharedPath);
        }
      }, onError: (_) {});

      // For sharing images/files when app is launched via Share menu
      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
        if (value.isNotEmpty && mounted) {
          final sharedPath = value.first.path;
          context.push('/share-receipt', extra: sharedPath);
          ReceiveSharingIntent.instance.reset();
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/add')) return 2;
    if (location.startsWith('/analytics')) return 3;
    if (location.startsWith('/more') || location.startsWith('/people') || location.startsWith('/categories')) return 4;
    return 0; // Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/expenses');
        break;
      case 2:
        context.push('/add');
        break;
      case 3:
        context.go('/analytics');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          DraggableFloatingActionButton(
            onPressed: () => context.push('/add'),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline, size: 30),
            selectedIcon: Icon(Icons.add_circle, size: 30),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
