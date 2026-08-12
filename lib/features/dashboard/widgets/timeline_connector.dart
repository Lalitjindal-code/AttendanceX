import 'package:flutter/material.dart';

class TimelineConnector extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isLast;
  final bool isPast;

  const TimelineConnector({
    super.key,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPast
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
        : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The vertical line
                Positioned(
                  top: isFirst ? 32 : 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? 32 : null,
                  child: Container(
                    width: 2,
                    color: color,
                  ),
                ),
                // The dot
                Positioned(
                  top: 32,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isPast
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPast
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
            child: child,
          )),
        ],
      ),
    );
  }
}
