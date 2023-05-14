import 'package:flutter/material.dart';

class HoverFadeWidget extends StatefulWidget {
  final Widget child;

  const HoverFadeWidget({required this.child});

  @override
  _HoverFadeWidgetState createState() => _HoverFadeWidgetState();
}

class _HoverFadeWidgetState extends State<HoverFadeWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        opacity: _isHovered ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: widget.child,
      ),
    );
  }
}
