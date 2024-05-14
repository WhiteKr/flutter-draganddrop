import 'package:draganddrop/my_draggable_widget.dart';
import 'package:draganddrop/types.dart';
import 'package:flutter/material.dart';

class SplitPanels extends StatefulWidget {
  const SplitPanels({
    super.key,
    this.columns = 5,
    this.itemSpacing = 4.0,
  });

  final int columns;
  final double itemSpacing;

  @override
  State<SplitPanels> createState() => _SplitPanelsState();
}

class _SplitPanelsState extends State<SplitPanels> {
  final List<String> upper = [];
  final List<String> lower = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];

  PanelLocation? dragStart;
  PanelLocation? dropPreview;
  String? hoveringData;

  void onDragStart(PanelLocation start) {
    final data = switch (start.$2) {
      Panel.lower => lower[start.$1],
      Panel.upper => upper[start.$1],
    };
    setState(() {
      dragStart = start;
      hoveringData = data;
    });
  }

  void updateDropPreview(PanelLocation update) =>
      setState(() => dropPreview = update);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutters = widget.columns + 1;
        final spaceForColumns =
            constraints.maxWidth - (widget.itemSpacing * gutters);
        final columnWidth = spaceForColumns / widget.columns;
        final itemSize = Size(columnWidth, columnWidth);

        return Stack(
          children: [
            Positioned(
              height: constraints.maxHeight / 2,
              width: constraints.maxWidth,
              top: 0,
              child: ItemPanel(
                crossAxisCount: widget.columns,
                dragStart: dragStart?.$2 == Panel.upper ? dragStart : null,
                items: upper,
                onDragStart: onDragStart,
                panel: Panel.upper,
                spacing: widget.itemSpacing,
              ),
            ),
            Positioned(
              height: 2,
              width: constraints.maxWidth,
              top: constraints.maxHeight / 2,
              child: const ColoredBox(
                color: Colors.black,
              ),
            ),
            Positioned(
              height: constraints.maxHeight / 2,
              width: constraints.maxWidth,
              bottom: 0,
              child: ItemPanel(
                crossAxisCount: widget.columns,
                dragStart: dragStart?.$2 == Panel.lower ? dragStart : null,
                items: lower,
                onDragStart: onDragStart,
                panel: Panel.lower,
                spacing: widget.itemSpacing,
              ),
            ),
          ],
        );
      },
    );
  }
}

class ItemPanel extends StatelessWidget {
  const ItemPanel({
    super.key,
    required this.crossAxisCount,
    required this.dragStart,
    required this.items,
    required this.onDragStart,
    required this.panel,
    required this.spacing,
  });

  final int crossAxisCount;
  final PanelLocation? dragStart;
  final List<String> items;
  final double spacing;

  final Function(PanelLocation) onDragStart;
  final Panel panel;

  @override
  Widget build(BuildContext context) {
    PanelLocation? dragStartCopy;
    if (dragStart != null) {
      dragStartCopy = dragStart!.copyWith();
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      padding: const EdgeInsets.all(4),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: items.asMap().entries.map(
        (MapEntry<int, String> entry) {
          Color textColor =
              entry.key == dragStartCopy?.$1 ? Colors.grey : Colors.white;

          Widget child = Center(
            child: Text(
              entry.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                color: textColor,
              ),
            ),
          );

          if (entry.key == dragStartCopy?.$1) {
            child = Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: child,
            );
          } else {
            child = Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: child,
            );
          }

          return Draggable(
            feedback: child,
            child: MyDraggableWidget(
              data: entry.value,
              onDragStart: () => onDragStart((entry.key, panel)),
              child: child,
            ),
          );
        },
      ).toList(),
    );
  }
}
