import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class A11yScreen extends StatelessWidget {
  final String label;
  final Widget child;

  const A11yScreen({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: label,
      child: child,
    );
  }
}

class A11yButton extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;
  final bool enabled;
  final bool selected;

  const A11yButton({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.enabled = true,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: label,
      hint: hint,
      child: ExcludeSemantics(child: child),
    );
  }
}

class A11yHeader extends StatelessWidget {
  final String label;
  final Widget child;

  const A11yHeader({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(header: true, label: label, child: child);
  }
}

class A11yLiveStatus extends StatelessWidget {
  final String message;
  final Widget child;

  const A11yLiveStatus({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(liveRegion: true, label: message, child: child);
  }
}

void announceForAccessibility(BuildContext context, String message) {
  SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
  );
}
