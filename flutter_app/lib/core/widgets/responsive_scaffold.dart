import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.primary,
    required this.secondary,
    this.breakpoint = 1100,
    this.spacing = 20,
  });

  final Widget primary;
  final Widget secondary;
  final double breakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: primary),
              SizedBox(width: spacing),
              Expanded(flex: 2, child: secondary),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            primary,
            SizedBox(height: spacing),
            secondary,
          ],
        );
      },
    );
  }
}
