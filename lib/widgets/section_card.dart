import 'package:flutter/material.dart';

import '../theme/app_gradients.dart';

class SectionCard extends StatefulWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool collapsible;
  final bool initiallyExpanded;
  final String? summary;

  const SectionCard({
    super.key,
    this.title,
    this.icon,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.summary,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: widget.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.title != null) ...[
              InkWell(
                onTap: widget.collapsible ? () => setState(() => _expanded = !_expanded) : null,
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppGradients.brand,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(widget.icon, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title!,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (!_expanded && widget.summary != null && widget.summary!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.summary!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.collapsible)
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? Padding(padding: const EdgeInsets.only(top: 18), child: widget.child)
                    : const SizedBox(width: double.infinity),
              ),
            ] else
              widget.child,
          ],
        ),
      ),
    );
  }
}
