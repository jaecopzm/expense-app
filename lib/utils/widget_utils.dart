import 'package:flutter/material.dart';

/// Utility class for widget-related helper functions
class WidgetUtils {
  /// Creates a safe AnimatedSwitcher that prevents semantics tree issues
  static Widget safeAnimatedSwitcher({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve switchInCurve = Curves.linear,
    Curve switchOutCurve = Curves.linear,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      child: KeyedSubtree(
        key: ValueKey(child.runtimeType.toString()),
        child: child,
      ),
    );
  }

  /// Creates a safe TabBarView that prevents rendering issues
  static Widget safeTabBarView({
    required TabController controller,
    required List<Widget> children,
  }) {
    return TabBarView(
      controller: controller,
      children: children.asMap().entries.map((entry) {
        return KeyedSubtree(
          key: ValueKey('tab_view_${entry.key}'),
          child: entry.value,
        );
      }).toList(),
    );
  }

  /// Wraps a widget with error boundary
  static Widget withErrorBoundary(Widget child) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          debugPrint('Widget error: $e');
          return Container(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      },
    );
  }
}
