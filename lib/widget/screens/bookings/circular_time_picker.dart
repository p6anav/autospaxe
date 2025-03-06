import 'dart:math';
import 'package:flutter/material.dart';

class CircleMenu extends StatefulWidget {
  final Function(int) onHoursChanged; // Callback for syncing time

  const CircleMenu({super.key, required this.onHoursChanged});

  @override
  _CircleMenuState createState() => _CircleMenuState();
}

class _CircleMenuState extends State<CircleMenu> {
  double _rotation = 0.0;
  int _selectedIndex = -1;
  bool isHourMode = true;

  List<int> get items => isHourMode
      ? List.generate(16, (index) => index) // 0-15 for hours
      : List.generate(16, (index) => (index + 1) * 3); // 3-48 in increments of 3

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _rotation += details.primaryDelta! * 0.5;
      _selectedIndex = _getSelectedIndex();
      
      if (_selectedIndex != -1) {
        widget.onHoursChanged(items[_selectedIndex]); // Send updated hours
      }
    });
  }

  int _getSelectedIndex() {
    int closestIndex = -1;
    double highestY = double.infinity;
    final double radius = 150;
    final double angleStep = 360 / items.length;

    for (int i = 0; i < items.length; i++) {
      double angle = (angleStep * i + _rotation) % 360;
      double radian = _degreeToRadian(angle);
      Offset textPosition = Offset(0, sin(radian) * radius);

      if (textPosition.dy < highestY) {
        highestY = textPosition.dy;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 5,
            child: SizedBox(
              width: 350,
              height: 350,
              child: CustomPaint(
                painter: CircleMenuPainter(
                  rotation: _rotation,
                  items: items,
                  selectedIndex: _selectedIndex,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            child: ModeToggleSwitch(
              isHourMode: isHourMode,
              onToggle: () {
                setState(() {
                  isHourMode = !isHourMode;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  double _degreeToRadian(double degree) => (degree * pi) / 180;
}

class CircleMenuPainter extends CustomPainter {
  final double rotation;
  final List<int> items;
  final int selectedIndex;

  CircleMenuPainter({
    required this.rotation,
    required this.items,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.height, size.width) * 0.4;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double angleStep = 360 / items.length;

    for (int i = 0; i < items.length; i++) {
      double angle = (angleStep * i + rotation) % 360;
      double radian = _degreeToRadian(angle);
      Offset textPosition = Offset(
        center.dx + cos(radian) * radius,
        center.dy + sin(radian) * radius,
      );

      bool isSelected = (i == selectedIndex);
      double textSize = isSelected ? 50 : 30;
      Color textColor = isSelected ? Colors.white : Colors.black87;

      // Create a glowing effect around selected number
      final paintCircle = Paint()
        ..color = isSelected ? Colors.deepPurple.withOpacity(0.9) : Colors.yellowAccent.withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..maskFilter = isSelected ? MaskFilter.blur(BlurStyle.normal, 10) : null;

      // Draw circular container
      canvas.drawCircle(textPosition, isSelected ? 35 : 25, paintCircle);

      // Draw number inside the circular container
      final textPainter = TextPainter(
        text: TextSpan(
          text: "${items[i]}",
          style: TextStyle(
            fontSize: textSize,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        textPosition - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(CircleMenuPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.selectedIndex != selectedIndex;
  }

  double _degreeToRadian(double degree) => (degree * pi) / 180;
}

// Mode Toggle Switch
class ModeToggleSwitch extends StatelessWidget {
  final bool isHourMode;
  final VoidCallback onToggle;

  const ModeToggleSwitch({
    super.key,
    required this.isHourMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 70,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(left: 10, child: _modeIcon(true)),
            Positioned(right: 10, child: _modeIcon(false)),

            // Sliding Toggle
            AnimatedAlign(
              duration: Duration(milliseconds: 300),
              alignment: isHourMode ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isHourMode ? Icons.access_time : Icons.timer,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeIcon(bool isHour) {
    return Icon(
      isHour ? Icons.access_time : Icons.timer,
      size: 18,
      color: Colors.black54,
    );
  }
}