import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DockScreen(),
    );
  }
}

class DockScreen extends StatefulWidget {
  @override
  _DockScreenState createState() => _DockScreenState();
}

class _DockScreenState extends State<DockScreen> {
  late List<IconData> dockItems;

  int? draggedIndex;
  int? currentIndex;
  int? newIndex;
  Offset dragStartPosition = Offset.zero;
  Offset dragCurrentPosition = Offset.zero;

  int? hoveredIndex;
  bool isDraggedInsideDock = true;

  @override
  void initState() {
    super.initState();
    dockItems = [
      Icons.window,
      Icons.search,
      Icons.folder,
      Icons.chat,
      Icons.web,
      Icons.calendar_today,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.65,
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: dockItems.asMap().entries.map((entry) {
              final index = entry.key;
              final icon = entry.value;
              final isDragged = draggedIndex == index;

              return GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    draggedIndex = index;
                    dragStartPosition = details.localPosition;
                    dragCurrentPosition = details.localPosition;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    dragCurrentPosition = details.localPosition;

                    final Offset newPosition = dragCurrentPosition - dragStartPosition;

                    // Check if the dragged icon is inside the dock area
                    final isInsideDock = _isInsideDockArea(details.globalPosition, context);
                    if (isInsideDock != isDraggedInsideDock) {
                      isDraggedInsideDock = isInsideDock;
                    }

                    if (isDraggedInsideDock) {
                      _handleReorderOnDrag(index, newPosition.dx);
                    }
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    draggedIndex = null;
                  });
                },
                child: MouseRegion(
                  onEnter: (_) => setState(() => hoveredIndex = index),
                  onExit: (_) => setState(() => hoveredIndex = null),
                  child: Transform.translate(
                    offset: isDragged ? dragCurrentPosition - dragStartPosition : Offset.zero,
                    child: _buildAnimatedIcon(icon, hoveredIndex == index, isDragged),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, bool isHovered, bool isDragged) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minWidth: 68),
      height: isHovered || isDragged ? 74 : 58,
      width: isHovered || isDragged ? 74 : 58,
      margin: const EdgeInsets.all(8),
      transform: Matrix4.identity()..translate(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: isHovered || isDragged ? 46 : 34,
        ),
      ),
    );
  }

  bool _isInsideDockArea(Offset globalPosition, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    final Size dockSize = box.size;

    return localPosition.dx >= 0 &&
        localPosition.dx <= dockSize.width &&
        localPosition.dy >= 0 &&
        localPosition.dy <= dockSize.height;
  }

  void _handleReorderOnDrag(int currentIndex, double deltaX) {
    if (draggedIndex == null) return;

    final draggedItem = dockItems[draggedIndex!];
    int targetIndex = (deltaX / 44).floor();  // Calculate target index based on movement
    targetIndex = targetIndex.clamp(currentIndex, dockItems.length - 1);

    if (targetIndex != currentIndex) {
      setState(() {
        dockItems.removeAt(draggedIndex!);
        dockItems.insert(targetIndex, draggedItem);
        draggedIndex = targetIndex;
        newIndex = targetIndex;
      });
    }
  }
}
